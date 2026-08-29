package crm

import (
	capabilities "example.com/domainry/m1-sales-crm/generated/capabilities"
	"example.com/domainry/m1-sales-crm/generated/schema"
	"testing"
)

func TestResolveConversionApprovalCreatesCustomerAndNotifiesRequester(t *testing.T) {
	requester := "east_sales"
	approvalStore := &testApprovalStore{
		record:  schema.ConversionApproval{ID: "approval-1", UpdatedAt: "approval-rev-1", LeadID: schema.NewConversionApprovalLeadIDReference("lead-1"), RequesterUser: &requester, Status: schema.ConversionApprovalStatusPending},
		updated: schema.ConversionApproval{ID: "approval-1", Status: schema.ConversionApprovalStatusApproved},
	}
	leadStore := &testLeadStore{record: ownedLead(schema.LeadStatusQualified, "125000.00"), updated: ownedLead(schema.LeadStatusConverted, "125000.00")}
	customers := &testCustomerStore{created: schema.Customer{ID: "customer-1"}}
	notifications := &testApprovalNotifications{}
	director := testPrincipal("sales_director")
	director.RoleKey = "sales_director"
	out, err := ResolveConversionApproval(t.Context(), capabilities.ResolveConversionApprovalCapabilities{Execution: testApprovalExecution{director, "approval-1"}, ConversionApproval: approvalStore, Lead: leadStore, Customer: customers, Notifications: notifications}, capabilities.ResolveConversionApprovalInput{RequestID: "approve-1", Resolution: schema.ConversionApprovalResolveConversionApprovalResolutionApproved})
	if err != nil || out.CustomerID == nil || out.Resolution != schema.ConversionApprovalResolveConversionApprovalResolutionApproved || customers.createCalls != 1 || leadStore.updateCalls != 1 || approvalStore.updateCalls != 1 || notifications.calls != 1 || notifications.last.RecipientUserIDs[0] != requester {
		t.Fatalf("approval result/effects mismatch: out=%+v customer=%d lead=%d approval=%d notification=%d err=%v", out, customers.createCalls, leadStore.updateCalls, approvalStore.updateCalls, notifications.calls, err)
	}
}
