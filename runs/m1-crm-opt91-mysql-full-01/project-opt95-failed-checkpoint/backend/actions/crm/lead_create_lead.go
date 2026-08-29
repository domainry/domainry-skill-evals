// This file is initial project-owned business source. Domainry will never overwrite it.
package crm

import (
	"context"
	capabilities "example.com/domainry/m1-sales-crm/generated/capabilities"
	"example.com/domainry/m1-sales-crm/generated/schema"
	"strings"
	"time"
)

// CreateLead implements the project-owned lead.create_lead Handler.
func CreateLead(ctx context.Context, caps capabilities.CreateLeadCapabilities, input capabilities.CreateLeadInput) (capabilities.CreateLeadOutput, error) {
	if caps.Execution == nil || caps.Lead == nil {
		return capabilities.CreateLeadOutput{}, businessError("lead.capability_required", "lead creation capabilities are unavailable")
	}
	principal := caps.Execution.Principal()
	if err := requirePrincipal(principal); err != nil {
		return capabilities.CreateLeadOutput{}, err
	}
	if strings.TrimSpace(input.CompanyName) == "" {
		return capabilities.CreateLeadOutput{}, businessError("lead.company_name_required", "company name is required")
	}
	now := time.Now().UTC()
	lead, err := caps.Lead.Create(ctx, schema.CreateLead{
		CompanyName: input.CompanyName, ContactName: input.ContactName, ContactPhone: input.ContactPhone,
		ExpectedAmount: input.ExpectedAmount, Source: schema.LeadSource(input.Source), Status: schema.LeadStatusNew,
		StatusChangedAt: &now,
	})
	if err != nil {
		return capabilities.CreateLeadOutput{}, err
	}
	return capabilities.CreateLeadOutput{LeadID: lead.ID, Status: schema.LeadCreateLeadStatusNew}, nil
}
