# Action lead.process_stale_lead_reminders

Project-owned implementation of 处理逾期跟进提醒

This file is generated. Implement business logic only in `actions/crm/lead_process_stale_lead_reminders.go` and tests in `actions/crm/lead_process_stale_lead_reminders_test.go`. The machine-readable scope is `generated/context/lead_process_stale_lead_reminders.json`.

## Typed input

- `run_date` (`date`, required): 运行日期


## Typed output

- `reminded_count` (`integer`, required): 提醒数
- `scanned_count` (`integer`, required): 扫描数


## Authorized objects

- `lead`: operations `get_for_update`, `list`; types `generated/schema/lead.gen.go`; data API `generated/data/lead.gen.go`
- `lead_reminder_delivery`: operations `conditional_update`, `create`, `list`; types `generated/schema/lead_reminder_delivery.gen.go`; data API `generated/data/lead_reminder_delivery.gen.go`


## Authorized Connector operations

- No Connector capabilities.


## Authorized notification operations

- notification.intent.dispatch event_type=lead.stale_followup via capabilities.Notifications.Dispatch or bounded DispatchBatch (1..200)


## Authorized file operations

- No file capability.


## Bounded batch contract

Authorized generated `*Batch` methods accept 1 through 200 inputs. Query and receipt results preserve input order and correspond one-to-one with inputs. A batch error returns no result slice. Reads may already have completed before a later read fails, but have no write effect. Mutations and notification intents remain staged inside this Action's single Runtime-owned transaction and commit together only after the Handler succeeds; project code must return any batch error. Every item inherits the invocation's Workspace, Principal, authorization grant, and data Scope. Notification source-event and dedupe identities remain required per item.

## Read order

- `generated/docs/lead_process_stale_lead_reminders.md`: focused Action contract and authorized domain surface
- `generated/capabilities/lead_process_stale_lead_reminders.gen.go`: typed Handler input, output, errors, and minimum capabilities; focus symbols: `ProcessStaleLeadRemindersInput`, `ProcessStaleLeadRemindersOutput`, `ProcessStaleLeadRemindersCapabilities`
- `generated/schema/lead.gen.go`: authorized object types and field contracts; focus symbols: `Lead`
- `generated/schema/lead_reminder_delivery.gen.go`: authorized object types and field contracts; focus symbols: `LeadReminderDelivery`
- `actions/crm/lead_process_stale_lead_reminders.go`: user-owned Action implementation
- `actions/crm/lead_process_stale_lead_reminders_test.go`: user-owned Action tests


Do not load or import Runtime internals, database handles, registries, workers, or unrelated generated domain files for this Action.
