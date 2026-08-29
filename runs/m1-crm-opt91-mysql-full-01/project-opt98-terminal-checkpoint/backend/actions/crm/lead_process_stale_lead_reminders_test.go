package crm

import (
	capabilities "example.com/domainry/m1-sales-crm/generated/capabilities"
	"example.com/domainry/m1-sales-crm/generated/schema"
	"testing"
	"time"
)

func TestProcessStaleLeadRemindersPersistsDedupeAndDispatches(t *testing.T) {
	leadStore := &testLeadStore{listed: []schema.Lead{ownedLead(schema.LeadStatusContacted, "500.00")}}
	deliveries := &testReminderStore{}
	notifications := &testReminderNotifications{}
	director := testPrincipal("sales_director")
	director.RoleKey = "sales_director"
	out, err := ProcessStaleLeadReminders(t.Context(), capabilities.ProcessStaleLeadRemindersCapabilities{Execution: testCreateExecution{director}, Lead: leadStore, LeadReminderDelivery: deliveries, Notifications: notifications}, capabilities.ProcessStaleLeadRemindersInput{RunDate: time.Date(2026, 8, 24, 0, 0, 0, 0, time.UTC)})
	if err != nil || out.ScannedCount != 1 || out.RemindedCount != 1 || leadStore.lockCalls != 1 || deliveries.createCalls != 1 || notifications.calls != 1 || notifications.last.RecipientUserIDs[0] != "east_sales" || notifications.last.Alert || notifications.last.GroupKey != "" {
		t.Fatalf("reminder result/effects mismatch: out=%+v delivery=%d notification=%d err=%v", out, deliveries.createCalls, notifications.calls, err)
	}
}

func TestProcessStaleLeadRemindersTouchesExistingDeliveryWithVersionedDedupeIntent(t *testing.T) {
	leadStore := &testLeadStore{listed: []schema.Lead{ownedLead(schema.LeadStatusContacted, "500.00")}}
	deliveries := &testReminderStore{exists: true}
	notifications := &testReminderNotifications{}
	director := testPrincipal("sales_director")
	director.RoleKey = "sales_director"
	out, err := ProcessStaleLeadReminders(t.Context(), capabilities.ProcessStaleLeadRemindersCapabilities{Execution: testCreateExecution{director}, Lead: leadStore, LeadReminderDelivery: deliveries, Notifications: notifications}, capabilities.ProcessStaleLeadRemindersInput{RunDate: time.Date(2026, 8, 24, 0, 0, 0, 0, time.UTC)})
	if err != nil || out.ScannedCount != 1 || out.RemindedCount != 0 || leadStore.lockCalls != 1 || deliveries.createCalls != 0 || deliveries.updateCalls != 1 || notifications.calls != 1 || notifications.last.SourceEventID != "stale:lead-1:2026-08-24:retry:revision-1" || notifications.last.DedupeKey != "stale:lead-1:2026-08-24" || notifications.last.Alert || notifications.last.GroupKey != "" {
		t.Fatalf("reminder retry mismatch: out=%+v creates=%d updates=%d notifications=%d err=%v", out, deliveries.createCalls, deliveries.updateCalls, notifications.calls, err)
	}
}
