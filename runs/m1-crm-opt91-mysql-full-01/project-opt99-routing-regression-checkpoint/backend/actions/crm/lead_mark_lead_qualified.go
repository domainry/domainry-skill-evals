// This file is initial project-owned business source. Domainry will never overwrite it.
package crm

import (
	"context"
	capabilities "example.com/domainry/m1-sales-crm/generated/capabilities"
	"example.com/domainry/m1-sales-crm/generated/data"
	"example.com/domainry/m1-sales-crm/generated/schema"
	"time"
)

// MarkLeadQualified implements the project-owned lead.mark_lead_qualified Handler.
func MarkLeadQualified(ctx context.Context, caps capabilities.MarkLeadQualifiedCapabilities, input capabilities.MarkLeadQualifiedInput) (capabilities.MarkLeadQualifiedOutput, error) {
	if caps.Execution == nil || caps.Lead == nil {
		return capabilities.MarkLeadQualifiedOutput{}, businessError("lead.capability_required", "lead transition capabilities are unavailable")
	}
	principal := caps.Execution.Principal()
	if err := requirePrincipal(principal); err != nil {
		return capabilities.MarkLeadQualifiedOutput{}, err
	}
	lead, err := caps.Lead.GetForUpdate(ctx, caps.Execution.TargetID())
	if err != nil {
		return capabilities.MarkLeadQualifiedOutput{}, err
	}
	if err := requireOwnedLead(lead, principal); err != nil {
		return capabilities.MarkLeadQualifiedOutput{}, err
	}
	expectedUpdatedAt := lead.UpdatedAt
	if input.ExpectedUpdatedAt != nil {
		expectedUpdatedAt = input.ExpectedUpdatedAt.UTC().Format(time.RFC3339Nano)
	}
	mutation := data.NewLeadUpdate(lead.ID).RequireOwnerUserEqual(principal.UserID, "lead.owner_required")
	if input.ExpectedUpdatedAt == nil {
		mutation = mutation.RequireStatusEqual(schema.LeadStatusContacted, "lead.invalid_transition")
	}
	updated, err := caps.Lead.ConditionalUpdate(ctx, mutation.WithExpectedUpdatedAt(expectedUpdatedAt).
		SetStatus(schema.LeadStatusQualified).SetStatusChangedAt(time.Now().UTC()))
	if err != nil {
		return capabilities.MarkLeadQualifiedOutput{}, err
	}
	return capabilities.MarkLeadQualifiedOutput{LeadID: updated.ID, Status: schema.LeadMarkLeadQualifiedStatusQualified}, nil
}
