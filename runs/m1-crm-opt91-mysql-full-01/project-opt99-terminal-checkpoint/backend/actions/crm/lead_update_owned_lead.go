// This file is initial project-owned business source. Domainry will never overwrite it.
package crm

import (
	"context"
	capabilities "example.com/domainry/m1-sales-crm/generated/capabilities"
	"example.com/domainry/m1-sales-crm/generated/data"
	"example.com/domainry/m1-sales-crm/generated/schema"
	"strings"
)

// UpdateOwnedLead implements the project-owned lead.update_owned_lead Handler.
func UpdateOwnedLead(ctx context.Context, caps capabilities.UpdateOwnedLeadCapabilities, input capabilities.UpdateOwnedLeadInput) (capabilities.UpdateOwnedLeadOutput, error) {
	if caps.Execution == nil || caps.Lead == nil {
		return capabilities.UpdateOwnedLeadOutput{}, businessError("lead.capability_required", "lead update capabilities are unavailable")
	}
	principal := caps.Execution.Principal()
	if err := requirePrincipal(principal); err != nil {
		return capabilities.UpdateOwnedLeadOutput{}, err
	}
	if strings.TrimSpace(input.ContactName) == "" {
		return capabilities.UpdateOwnedLeadOutput{}, businessError("lead.contact_name_required", "contact name is required")
	}
	lead, err := caps.Lead.GetForUpdate(ctx, caps.Execution.TargetID())
	if err != nil {
		return capabilities.UpdateOwnedLeadOutput{}, err
	}
	if err := requireOwnedLead(lead, principal); err != nil {
		return capabilities.UpdateOwnedLeadOutput{}, err
	}
	if lead.Status == schema.LeadStatusConverted || lead.Status == schema.LeadStatusLost {
		return capabilities.UpdateOwnedLeadOutput{}, businessError("lead.terminal", "terminal leads cannot be updated")
	}
	mutation := data.NewLeadUpdate(lead.ID).
		RequireOwnerUserEqual(principal.UserID, "lead.owner_required").
		RequireStatusNotEqual(schema.LeadStatusConverted, "lead.terminal").
		WithExpectedUpdatedAt(lead.UpdatedAt).
		SetContactName(input.ContactName)
	if input.ContactPhone != nil {
		mutation = mutation.SetContactPhone(*input.ContactPhone)
	}
	if input.ExpectedAmount != nil {
		mutation = mutation.SetExpectedAmount(*input.ExpectedAmount)
	}
	if input.Source != nil {
		mutation = mutation.SetSource(schema.LeadSource(*input.Source))
	}
	updated, err := caps.Lead.ConditionalUpdate(ctx, mutation)
	if err != nil {
		return capabilities.UpdateOwnedLeadOutput{}, err
	}
	return capabilities.UpdateOwnedLeadOutput{LeadID: updated.ID, Updated: true}, nil
}
