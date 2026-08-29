// This file is initial project-owned business source. Domainry will never overwrite it.
package crm

import (
	"context"
	capabilities "example.com/domainry/m1-sales-crm/generated/capabilities"
	"example.com/domainry/m1-sales-crm/generated/data"
	"example.com/domainry/m1-sales-crm/generated/schema"
	"time"
)

// MarkLeadContacted implements the project-owned lead.mark_lead_contacted Handler.
func MarkLeadContacted(ctx context.Context, caps capabilities.MarkLeadContactedCapabilities, input capabilities.MarkLeadContactedInput) (capabilities.MarkLeadContactedOutput, error) {
	if caps.Execution == nil || caps.Lead == nil {
		return capabilities.MarkLeadContactedOutput{}, businessError("lead.capability_required", "lead transition capabilities are unavailable")
	}
	principal := caps.Execution.Principal()
	if err := requirePrincipal(principal); err != nil {
		return capabilities.MarkLeadContactedOutput{}, err
	}
	lead, err := caps.Lead.GetForUpdate(ctx, caps.Execution.TargetID())
	if err != nil {
		return capabilities.MarkLeadContactedOutput{}, err
	}
	if err := requireOwnedLead(lead, principal); err != nil {
		return capabilities.MarkLeadContactedOutput{}, err
	}
	expectedUpdatedAt := lead.UpdatedAt
	if input.ExpectedUpdatedAt != nil {
		expectedUpdatedAt = input.ExpectedUpdatedAt.UTC().Format(time.RFC3339Nano)
	}
	mutation := data.NewLeadUpdate(lead.ID).RequireOwnerUserEqual(principal.UserID, "lead.owner_required")
	if input.ExpectedUpdatedAt == nil {
		mutation = mutation.RequireStatusEqual(schema.LeadStatusNew, "lead.invalid_transition")
	}
	updated, err := caps.Lead.ConditionalUpdate(ctx, mutation.WithExpectedUpdatedAt(expectedUpdatedAt).
		SetStatus(schema.LeadStatusContacted).SetStatusChangedAt(time.Now().UTC()))
	if err != nil {
		return capabilities.MarkLeadContactedOutput{}, err
	}
	return capabilities.MarkLeadContactedOutput{LeadID: updated.ID, Status: schema.LeadMarkLeadContactedStatusContacted}, nil
}
