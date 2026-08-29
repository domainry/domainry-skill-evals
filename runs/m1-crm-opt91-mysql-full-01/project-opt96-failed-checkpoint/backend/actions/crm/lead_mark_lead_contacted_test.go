package crm

import (
	capabilities "example.com/domainry/m1-sales-crm/generated/capabilities"
	"example.com/domainry/m1-sales-crm/generated/schema"
	"testing"
)

func TestMarkLeadContactedTransitionsNewLead(t *testing.T) {
	store := &testLeadStore{record: ownedLead(schema.LeadStatusNew, "100.00"), updated: ownedLead(schema.LeadStatusContacted, "100.00")}
	out, err := MarkLeadContacted(t.Context(), capabilities.MarkLeadContactedCapabilities{Execution: testLeadExecution{testPrincipal("east_sales"), "lead-1"}, Lead: store}, capabilities.MarkLeadContactedInput{RequestID: "contact-1"})
	if err != nil || out.Status != schema.LeadMarkLeadContactedStatusContacted || store.updateCalls != 1 {
		t.Fatalf("transition mismatch: out=%+v calls=%d err=%v", out, store.updateCalls, err)
	}
}
