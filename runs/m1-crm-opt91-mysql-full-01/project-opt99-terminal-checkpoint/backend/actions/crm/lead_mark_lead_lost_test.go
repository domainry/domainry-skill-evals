package crm

import (
	capabilities "example.com/domainry/m1-sales-crm/generated/capabilities"
	"example.com/domainry/m1-sales-crm/generated/schema"
	"testing"
)

func TestMarkLeadLostTransitionsQualifiedLead(t *testing.T) {
	store := &testLeadStore{record: ownedLead(schema.LeadStatusQualified, "100.00"), updated: ownedLead(schema.LeadStatusLost, "100.00")}
	out, err := MarkLeadLost(t.Context(), capabilities.MarkLeadLostCapabilities{Execution: testLeadExecution{testPrincipal("east_sales"), "lead-1"}, Lead: store}, capabilities.MarkLeadLostInput{RequestID: "lost-1"})
	if err != nil || out.Status != schema.LeadMarkLeadLostStatusLost || store.updateCalls != 1 {
		t.Fatalf("transition mismatch: out=%+v calls=%d err=%v", out, store.updateCalls, err)
	}
}
