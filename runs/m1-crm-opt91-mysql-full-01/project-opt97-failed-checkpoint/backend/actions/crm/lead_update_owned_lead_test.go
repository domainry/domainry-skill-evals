package crm

import (
	capabilities "example.com/domainry/m1-sales-crm/generated/capabilities"
	"example.com/domainry/m1-sales-crm/generated/schema"
	"testing"
)

func TestUpdateOwnedLeadUsesConditionalMutation(t *testing.T) {
	store := &testLeadStore{record: ownedLead(schema.LeadStatusContacted, "1200.00"), updated: ownedLead(schema.LeadStatusContacted, "1500.00")}
	out, err := UpdateOwnedLead(t.Context(), capabilities.UpdateOwnedLeadCapabilities{Execution: testLeadExecution{testPrincipal("east_sales"), "lead-1"}, Lead: store}, capabilities.UpdateOwnedLeadInput{ContactName: "Alice", RequestID: "update-1"})
	if err != nil || !out.Updated || out.LeadID != "lead-1" || store.updateCalls != 1 {
		t.Fatalf("update result/effect mismatch: out=%+v calls=%d err=%v", out, store.updateCalls, err)
	}
}
