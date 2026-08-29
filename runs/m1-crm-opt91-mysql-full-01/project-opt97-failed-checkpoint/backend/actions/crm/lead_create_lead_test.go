package crm

import (
	capabilities "example.com/domainry/m1-sales-crm/generated/capabilities"
	"example.com/domainry/m1-sales-crm/generated/schema"
	"testing"
)

func TestCreateLeadCreatesNewOwnedRecord(t *testing.T) {
	store := &testLeadStore{created: schema.Lead{ID: "lead-created", Status: schema.LeadStatusNew}}
	out, err := CreateLead(t.Context(), capabilities.CreateLeadCapabilities{Execution: testCreateExecution{testPrincipal("east_sales")}, Lead: store}, capabilities.CreateLeadInput{CompanyName: "Acme", ExpectedAmount: "999.50", Source: schema.LeadCreateLeadSourceWebsite, RequestID: "create-1"})
	if err != nil || out.LeadID != "lead-created" || out.Status != schema.LeadCreateLeadStatusNew || store.createCalls != 1 {
		t.Fatalf("create result/effect mismatch: out=%+v calls=%d err=%v", out, store.createCalls, err)
	}
}
