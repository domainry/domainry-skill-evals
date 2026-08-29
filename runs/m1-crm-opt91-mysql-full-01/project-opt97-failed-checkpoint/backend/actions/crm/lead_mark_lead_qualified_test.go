package crm

import (
	capabilities "example.com/domainry/m1-sales-crm/generated/capabilities"
	"example.com/domainry/m1-sales-crm/generated/schema"
	"testing"
)

func TestMarkLeadQualifiedTransitionsContactedLead(t *testing.T) {
	store := &testLeadStore{record: ownedLead(schema.LeadStatusContacted, "100.00"), updated: ownedLead(schema.LeadStatusQualified, "100.00")}
	out, err := MarkLeadQualified(t.Context(), capabilities.MarkLeadQualifiedCapabilities{Execution: testLeadExecution{testPrincipal("east_sales"), "lead-1"}, Lead: store}, capabilities.MarkLeadQualifiedInput{RequestID: "qualify-1"})
	if err != nil || out.Status != schema.LeadMarkLeadQualifiedStatusQualified || store.updateCalls != 1 {
		t.Fatalf("transition mismatch: out=%+v calls=%d err=%v", out, store.updateCalls, err)
	}
}
