package crm

import (
	"context"
	"strings"
	"time"

	capabilities "example.com/domainry/m1-sales-crm/generated/capabilities"
	"example.com/domainry/m1-sales-crm/generated/data"
	"example.com/domainry/m1-sales-crm/generated/schema"
)

type leadMutationCapability interface {
	GetForUpdate(context.Context, schema.LeadID) (schema.Lead, error)
	ConditionalUpdate(context.Context, data.LeadUpdateMutation) (schema.Lead, error)
}

func businessError(code, message string) error {
	return &capabilities.BusinessError{Code: code, Message: message}
}

func requirePrincipal(principal capabilities.Principal) error {
	if !principal.Known || strings.TrimSpace(principal.UserID) == "" {
		return businessError("crm.principal_required", "an authenticated project principal is required")
	}
	return nil
}

func requireOwnedLead(lead schema.Lead, principal capabilities.Principal) error {
	if lead.OwnerUser == nil || *lead.OwnerUser != principal.UserID {
		return businessError("lead.owner_required", "only the lead owner may mutate this lead")
	}
	return nil
}

func transitionOwnedLead(ctx context.Context, leadStore leadMutationCapability, target schema.LeadID, principal capabilities.Principal, from, to schema.LeadStatus) (schema.Lead, error) {
	lead, err := leadStore.GetForUpdate(ctx, target)
	if err != nil {
		return schema.Lead{}, err
	}
	if err := requireOwnedLead(lead, principal); err != nil {
		return schema.Lead{}, err
	}
	if lead.Status != from {
		return schema.Lead{}, businessError("lead.invalid_transition", "lead is not in the required source state")
	}
	mutation := data.NewLeadUpdate(lead.ID).
		RequireOwnerUserEqual(principal.UserID, "lead.owner_required").
		RequireStatusEqual(from, "lead.invalid_transition").
		WithExpectedUpdatedAt(lead.UpdatedAt).
		SetStatus(to).
		SetStatusChangedAt(time.Now().UTC())
	return leadStore.ConditionalUpdate(ctx, mutation)
}

func customerFromLead(lead schema.Lead) schema.CreateCustomer {
	return schema.CreateCustomer{
		CompanyName:    lead.CompanyName,
		ContactName:    lead.ContactName,
		ContactPhone:   lead.ContactPhone,
		ExpectedAmount: schema.CustomerExpectedAmount(lead.ExpectedAmount),
		Source:         schema.CustomerSource(lead.Source),
		SourceLeadID:   schema.NewCustomerSourceLeadIDReference(lead.ID),
	}
}

func amountAtLeast(amount schema.LeadExpectedAmount, threshold string) bool {
	value := strings.TrimSpace(string(amount))
	parts := strings.SplitN(value, ".", 2)
	whole := strings.TrimLeft(parts[0], "0")
	if whole == "" {
		whole = "0"
	}
	thresholdWhole := strings.TrimLeft(strings.SplitN(threshold, ".", 2)[0], "0")
	if thresholdWhole == "" {
		thresholdWhole = "0"
	}
	if len(whole) != len(thresholdWhole) {
		return len(whole) > len(thresholdWhole)
	}
	return whole >= thresholdWhole
}
