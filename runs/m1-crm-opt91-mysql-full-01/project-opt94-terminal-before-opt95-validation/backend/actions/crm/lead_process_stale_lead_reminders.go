// This file is initial project-owned business source. Domainry will never overwrite it.
package crm

import (
	"context"
	capabilities "example.com/domainry/m1-sales-crm/generated/capabilities"
	"example.com/domainry/m1-sales-crm/generated/data"
	"example.com/domainry/m1-sales-crm/generated/schema"
	"fmt"
	"time"
)

// ProcessStaleLeadReminders implements the project-owned lead.process_stale_lead_reminders Handler.
func ProcessStaleLeadReminders(ctx context.Context, caps capabilities.ProcessStaleLeadRemindersCapabilities, input capabilities.ProcessStaleLeadRemindersInput) (capabilities.ProcessStaleLeadRemindersOutput, error) {
	if caps.Execution == nil || caps.Lead == nil || caps.LeadReminderDelivery == nil || caps.Notifications == nil {
		return capabilities.ProcessStaleLeadRemindersOutput{}, businessError("lead_reminder.capability_required", "reminder capabilities are unavailable")
	}
	if err := requirePrincipal(caps.Execution.Principal()); err != nil {
		return capabilities.ProcessStaleLeadRemindersOutput{}, err
	}
	runDate := time.Date(input.RunDate.Year(), input.RunDate.Month(), input.RunDate.Day(), 0, 0, 0, 0, time.UTC)
	cutoff := runDate.AddDate(0, 0, -7)
	leads, err := caps.Lead.List(ctx, data.NewLeadQuery().
		WhereStatusEqual(schema.LeadStatusContacted).
		WhereStatusChangedAtLessThan(cutoff).
		OrderByIDAscending().Page(1, 200))
	if err != nil {
		return capabilities.ProcessStaleLeadRemindersOutput{}, err
	}
	leadIDs := make([]schema.LeadID, 0, len(leads))
	for _, lead := range leads {
		leadIDs = append(leadIDs, lead.ID)
	}
	if len(leadIDs) == 0 {
		return capabilities.ProcessStaleLeadRemindersOutput{}, nil
	}
	// Lock the stable candidate set before reading or writing delivery dedupe
	// rows. Concurrent invocations for the same run date therefore serialize
	// before either can decide that a delivery is missing.
	leads, err = caps.Lead.GetForUpdateBatch(ctx, leadIDs)
	if err != nil {
		return capabilities.ProcessStaleLeadRemindersOutput{}, err
	}
	dedupeQueries := make([]data.LeadReminderDeliveryQuery, 0, len(leads))
	eligible := make([]schema.Lead, 0, len(leads))
	for _, lead := range leads {
		if lead.Status != schema.LeadStatusContacted || lead.StatusChangedAt == nil || !lead.StatusChangedAt.Before(cutoff) || lead.OwnerUser == nil || *lead.OwnerUser == "" {
			continue
		}
		dedupeKey := fmt.Sprintf("stale:%s:%s", lead.ID, runDate.Format("2006-01-02"))
		eligible = append(eligible, lead)
		dedupeQueries = append(dedupeQueries, data.NewLeadReminderDeliveryQuery().
			WhereDedupeKeyEqual(dedupeKey).
			OrderByIDAscending().
			Page(1, 1))
	}
	if len(dedupeQueries) == 0 {
		return capabilities.ProcessStaleLeadRemindersOutput{ScannedCount: int64(len(leads))}, nil
	}
	existingPages, err := caps.LeadReminderDelivery.ListBatch(ctx, dedupeQueries)
	if err != nil {
		return capabilities.ProcessStaleLeadRemindersOutput{}, err
	}
	now := time.Now().UTC()
	creates := make([]schema.CreateLeadReminderDelivery, 0, len(eligible))
	updates := make([]data.LeadReminderDeliveryUpdateMutation, 0, len(eligible))
	intents := make([]capabilities.ProcessStaleLeadRemindersNotificationIntent, 0, len(eligible))
	for index, lead := range eligible {
		dedupeKey := fmt.Sprintf("stale:%s:%s", lead.ID, runDate.Format("2006-01-02"))
		sourceEventID := dedupeKey + ":new:" + lead.UpdatedAt
		if len(existingPages[index]) == 0 {
			creates = append(creates, schema.CreateLeadReminderDelivery{DedupeKey: dedupeKey, LeadID: schema.NewLeadReminderDeliveryLeadIDReference(lead.ID), RecipientUser: *lead.OwnerUser, ReminderDate: runDate, SentAt: now, Status: schema.LeadReminderDeliveryStatusSent})
		} else {
			existing := existingPages[index][0]
			sourceEventID = dedupeKey + ":retry:" + existing.UpdatedAt
			updates = append(updates, data.NewLeadReminderDeliveryUpdate(existing.ID).
				RequireDedupeKeyEqual(dedupeKey, "lead_reminder.delivery_changed").
				WithExpectedUpdatedAt(existing.UpdatedAt).
				SetSentAt(now).
				SetStatus(schema.LeadReminderDeliveryStatusSent))
		}
		companyName := lead.CompanyName
		intents = append(intents, capabilities.ProcessStaleLeadRemindersNotificationIntent{EventType: "lead.stale_followup", SourceEventID: sourceEventID, RecipientUserIDs: []string{*lead.OwnerUser}, Surface: "business_workspace", SubjectObjectKey: "lead", SubjectRecordID: string(lead.ID), SubjectVersion: lead.UpdatedAt, DedupeKey: dedupeKey, OccurredAt: now, Variables: []capabilities.ProcessStaleLeadRemindersNotificationVariable{{Key: "company_name", StringValue: &companyName}}})
	}
	createdCount := int64(0)
	if len(creates) > 0 {
		if _, err := caps.LeadReminderDelivery.CreateBatch(ctx, creates); err != nil {
			return capabilities.ProcessStaleLeadRemindersOutput{}, err
		}
		createdCount = int64(len(creates))
	}
	if len(updates) > 0 {
		if _, err := caps.LeadReminderDelivery.ConditionalUpdateBatch(ctx, updates); err != nil {
			return capabilities.ProcessStaleLeadRemindersOutput{}, err
		}
	}
	if len(intents) > 0 {
		if _, err := caps.Notifications.DispatchBatch(ctx, intents); err != nil {
			return capabilities.ProcessStaleLeadRemindersOutput{}, err
		}
	}
	return capabilities.ProcessStaleLeadRemindersOutput{ScannedCount: int64(len(leads)), RemindedCount: createdCount}, nil
}
