package crm

import (
	capabilities "example.com/domainry/m1-sales-crm/generated/capabilities"
	"example.com/domainry/m1-sales-crm/generated/schema"
	"testing"
)

func TestRequestLeadConversionRoutesByExactThreshold(t *testing.T) {
	t.Run("below threshold converts atomically", func(t *testing.T) {
		leadStore := &testLeadStore{record: ownedLead(schema.LeadStatusQualified, "99999.99"), updated: ownedLead(schema.LeadStatusConverted, "99999.99")}
		customers := &testCustomerStore{created: schema.Customer{ID: "customer-1"}}
		approvals := &testApprovalStore{}
		out, err := RequestLeadConversion(t.Context(), capabilities.RequestLeadConversionCapabilities{Execution: testLeadExecution{testPrincipal("east_sales"), "lead-1"}, Lead: leadStore, Customer: customers, ConversionApproval: approvals}, capabilities.RequestLeadConversionInput{RequestID: "convert-low"})
		if err != nil || out.Result != schema.LeadRequestLeadConversionResultConverted || out.CustomerID == nil || customers.createCalls != 1 || leadStore.updateCalls != 1 || approvals.createCalls != 0 {
			t.Fatalf("direct conversion mismatch: out=%+v customer=%d update=%d approval=%d err=%v", out, customers.createCalls, leadStore.updateCalls, approvals.createCalls, err)
		}
	})
	t.Run("threshold amount creates pending approval", func(t *testing.T) {
		leadStore := &testLeadStore{record: ownedLead(schema.LeadStatusQualified, "100000.00")}
		customers := &testCustomerStore{}
		approvals := &testApprovalStore{created: schema.ConversionApproval{ID: "approval-1", Status: schema.ConversionApprovalStatusPending}}
		out, err := RequestLeadConversion(t.Context(), capabilities.RequestLeadConversionCapabilities{Execution: testLeadExecution{testPrincipal("east_sales"), "lead-1"}, Lead: leadStore, Customer: customers, ConversionApproval: approvals}, capabilities.RequestLeadConversionInput{RequestID: "convert-high"})
		if err != nil || out.Result != schema.LeadRequestLeadConversionResultApprovalPending || out.ApprovalID == nil || approvals.createCalls != 1 || customers.createCalls != 0 || leadStore.updateCalls != 1 {
			t.Fatalf("approval route mismatch: out=%+v customer=%d update=%d approval=%d err=%v", out, customers.createCalls, leadStore.updateCalls, approvals.createCalls, err)
		}
	})
}
