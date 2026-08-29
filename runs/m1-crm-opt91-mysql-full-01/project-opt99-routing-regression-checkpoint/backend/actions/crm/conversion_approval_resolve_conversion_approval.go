// This file is initial project-owned business source. Domainry will never overwrite it.
package crm

import (
	"context"
	capabilities "example.com/domainry/m1-sales-crm/generated/capabilities"
	"example.com/domainry/m1-sales-crm/generated/data"
	"example.com/domainry/m1-sales-crm/generated/schema"
	"time"
)

// ResolveConversionApproval implements the project-owned conversion_approval.resolve_conversion_approval Handler.
func ResolveConversionApproval(ctx context.Context, caps capabilities.ResolveConversionApprovalCapabilities, input capabilities.ResolveConversionApprovalInput) (capabilities.ResolveConversionApprovalOutput, error) {
	if caps.Execution == nil || caps.ConversionApproval == nil || caps.Lead == nil || caps.Customer == nil || caps.Notifications == nil {
		return capabilities.ResolveConversionApprovalOutput{}, businessError("conversion_approval.capability_required", "approval capabilities are unavailable")
	}
	principal := caps.Execution.Principal()
	if err := requirePrincipal(principal); err != nil {
		return capabilities.ResolveConversionApprovalOutput{}, err
	}
	approval, err := caps.ConversionApproval.GetForUpdate(ctx, caps.Execution.TargetID())
	if err != nil {
		return capabilities.ResolveConversionApprovalOutput{}, err
	}
	if approval.Status != schema.ConversionApprovalStatusPending {
		return capabilities.ResolveConversionApprovalOutput{}, businessError("conversion_approval.already_resolved", "approval is already terminal")
	}
	leadID := approval.LeadID.ID()
	lead, err := caps.Lead.GetForUpdate(ctx, leadID)
	if err != nil {
		return capabilities.ResolveConversionApprovalOutput{}, err
	}
	if lead.Status != schema.LeadStatusQualified {
		return capabilities.ResolveConversionApprovalOutput{}, businessError("lead.conversion_requires_qualified", "approval target is no longer qualified")
	}
	if approval.RequesterUser == nil || *approval.RequesterUser == "" {
		return capabilities.ResolveConversionApprovalOutput{}, businessError("conversion_approval.requester_required", "approval requester identity is missing")
	}
	now := time.Now().UTC()
	resolution := input.Resolution
	status := schema.ConversionApprovalStatusRejected
	rejectionReason := "未提供原因"
	var customerID *schema.CustomerID
	if resolution == schema.ConversionApprovalResolveConversionApprovalResolutionApproved {
		status = schema.ConversionApprovalStatusApproved
		customer, err := caps.Customer.Create(ctx, customerFromLead(lead))
		if err != nil {
			return capabilities.ResolveConversionApprovalOutput{}, err
		}
		customerID = &customer.ID
		_, err = caps.Lead.ConditionalUpdate(ctx, data.NewLeadUpdate(lead.ID).
			RequireStatusEqual(schema.LeadStatusQualified, "lead.conversion_requires_qualified").
			WithExpectedUpdatedAt(lead.UpdatedAt).
			SetStatus(schema.LeadStatusConverted).
			SetStatusChangedAt(now))
		if err != nil {
			return capabilities.ResolveConversionApprovalOutput{}, err
		}
	} else if resolution == schema.ConversionApprovalResolveConversionApprovalResolutionRejected {
		if input.Comment != nil && *input.Comment != "" {
			rejectionReason = *input.Comment
		}
	} else {
		return capabilities.ResolveConversionApprovalOutput{}, businessError("conversion_approval.resolution_invalid", "resolution must be approved or rejected")
	}
	mutation := data.NewConversionApprovalUpdate(approval.ID).
		RequireStatusEqual(schema.ConversionApprovalStatusPending, "conversion_approval.already_resolved").
		WithExpectedUpdatedAt(approval.UpdatedAt).
		SetStatus(status).
		SetDecidedBy(principal.UserID).
		SetDecidedAt(now)
	if input.Comment != nil {
		mutation = mutation.SetDecisionReason(*input.Comment)
	}
	updated, err := caps.ConversionApproval.ConditionalUpdate(ctx, mutation)
	if err != nil {
		return capabilities.ResolveConversionApprovalOutput{}, err
	}
	if resolution == schema.ConversionApprovalResolveConversionApprovalResolutionApproved {
		_, err = caps.Notifications.Dispatch(ctx, capabilities.ResolveConversionApprovalNotificationIntent{
			EventType: "lead.conversion_approved", SourceEventID: input.RequestID, RecipientUserIDs: []string{*approval.RequesterUser},
			Surface: "business_workspace", SubjectObjectKey: "lead", SubjectRecordID: string(lead.ID), SubjectVersion: lead.UpdatedAt,
			DedupeKey: input.RequestID, GroupKey: "lead:" + string(lead.ID), OccurredAt: now,
			Variables: []capabilities.ResolveConversionApprovalNotificationVariable{{Key: "company_name", StringValue: &lead.CompanyName}},
		})
	} else {
		_, err = caps.Notifications.Dispatch(ctx, capabilities.ResolveConversionApprovalNotificationIntent{
			EventType: "lead.conversion_rejected", SourceEventID: input.RequestID, RecipientUserIDs: []string{*approval.RequesterUser},
			Surface: "business_workspace", SubjectObjectKey: "lead", SubjectRecordID: string(lead.ID), SubjectVersion: lead.UpdatedAt,
			DedupeKey: input.RequestID, GroupKey: "lead:" + string(lead.ID), OccurredAt: now,
			Variables: []capabilities.ResolveConversionApprovalNotificationVariable{
				{Key: "company_name", StringValue: &lead.CompanyName}, {Key: "reason", StringValue: &rejectionReason},
			},
		})
	}
	if err != nil {
		return capabilities.ResolveConversionApprovalOutput{}, err
	}
	return capabilities.ResolveConversionApprovalOutput{ApprovalID: updated.ID, LeadID: lead.ID, Resolution: resolution, CustomerID: customerID}, nil
}
