// This file is initial project-owned business source. Domainry will never overwrite it.
package crm

import (
	"context"
	capabilities "example.com/domainry/m1-sales-crm/generated/capabilities"
	"example.com/domainry/m1-sales-crm/generated/data"
	"example.com/domainry/m1-sales-crm/generated/schema"
	"time"
)

// RequestLeadConversion implements the project-owned lead.request_lead_conversion Handler.
func RequestLeadConversion(ctx context.Context, caps capabilities.RequestLeadConversionCapabilities, input capabilities.RequestLeadConversionInput) (capabilities.RequestLeadConversionOutput, error) {
	_ = input
	if caps.Execution == nil || caps.Lead == nil || caps.Customer == nil || caps.ConversionApproval == nil {
		return capabilities.RequestLeadConversionOutput{}, businessError("lead.capability_required", "conversion capabilities are unavailable")
	}
	principal := caps.Execution.Principal()
	if err := requirePrincipal(principal); err != nil {
		return capabilities.RequestLeadConversionOutput{}, err
	}
	lead, err := caps.Lead.GetForUpdate(ctx, caps.Execution.TargetID())
	if err != nil {
		return capabilities.RequestLeadConversionOutput{}, err
	}
	if err := requireOwnedLead(lead, principal); err != nil {
		return capabilities.RequestLeadConversionOutput{}, err
	}
	if lead.Status != schema.LeadStatusQualified {
		return capabilities.RequestLeadConversionOutput{}, businessError("lead.conversion_requires_qualified", "only qualified leads may be converted")
	}
	if amountAtLeast(lead.ExpectedAmount, "100000.00") {
		_, err = caps.Lead.ConditionalUpdate(ctx, data.NewLeadUpdate(lead.ID).
			RequireOwnerUserEqual(principal.UserID, "lead.owner_required").
			RequireStatusEqual(schema.LeadStatusQualified, "lead.conversion_requires_qualified").
			WithExpectedUpdatedAt(lead.UpdatedAt).
			SetStatus(schema.LeadStatusQualified))
		if err != nil {
			return capabilities.RequestLeadConversionOutput{}, err
		}
		approval, err := caps.ConversionApproval.Create(ctx, schema.CreateConversionApproval{
			LeadID: schema.NewConversionApprovalLeadIDReference(lead.ID), Status: schema.ConversionApprovalStatusPending,
		})
		if err != nil {
			return capabilities.RequestLeadConversionOutput{}, err
		}
		approvalID := approval.ID
		return capabilities.RequestLeadConversionOutput{LeadID: lead.ID, Result: schema.LeadRequestLeadConversionResultApprovalPending, ApprovalID: &approvalID}, nil
	}
	customer, err := caps.Customer.Create(ctx, customerFromLead(lead))
	if err != nil {
		return capabilities.RequestLeadConversionOutput{}, err
	}
	now := time.Now().UTC()
	_, err = caps.Lead.ConditionalUpdate(ctx, data.NewLeadUpdate(lead.ID).
		RequireOwnerUserEqual(principal.UserID, "lead.owner_required").
		RequireStatusEqual(schema.LeadStatusQualified, "lead.conversion_requires_qualified").
		WithExpectedUpdatedAt(lead.UpdatedAt).
		SetStatus(schema.LeadStatusConverted).
		SetStatusChangedAt(now))
	if err != nil {
		return capabilities.RequestLeadConversionOutput{}, err
	}
	customerID := customer.ID
	return capabilities.RequestLeadConversionOutput{LeadID: lead.ID, Result: schema.LeadRequestLeadConversionResultConverted, CustomerID: &customerID}, nil
}
