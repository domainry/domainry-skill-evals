# Action lead.mark_lead_lost

Project-owned implementation of 标记流失

This file is generated. Implement business logic only in `actions/crm/lead_mark_lead_lost.go` and tests in `actions/crm/lead_mark_lead_lost_test.go`. The machine-readable scope is `generated/context/lead_mark_lead_lost.json`.

## Typed input

- `expected_updated_at` (`datetime`, optional): 预期版本
- `request_id` (`text`, required): 请求 ID


## Typed output

- `lead_id` (`object_id`, required): 线索 ID
- `status` (`value_domain`, required): 状态


## Authorized objects

- `lead`: operations `conditional_update`, `get_for_update`; types `generated/schema/lead.gen.go`; data API `generated/data/lead.gen.go`


## Authorized Connector operations

- No Connector capabilities.


## Authorized notification operations

- No notification dispatch capability.


## Authorized file operations

- No file capability.


## Bounded batch contract

Authorized generated `*Batch` methods accept 1 through 200 inputs. Query and receipt results preserve input order and correspond one-to-one with inputs. A batch error returns no result slice. Reads may already have completed before a later read fails, but have no write effect. Mutations and notification intents remain staged inside this Action's single Runtime-owned transaction and commit together only after the Handler succeeds; project code must return any batch error. Every item inherits the invocation's Workspace, Principal, authorization grant, and data Scope. Notification source-event and dedupe identities remain required per item.

## Read order

- `generated/docs/lead_mark_lead_lost.md`: focused Action contract and authorized domain surface
- `generated/capabilities/lead_mark_lead_lost.gen.go`: typed Handler input, output, errors, and minimum capabilities; focus symbols: `MarkLeadLostInput`, `MarkLeadLostOutput`, `MarkLeadLostCapabilities`
- `generated/schema/lead.gen.go`: authorized object types and field contracts; focus symbols: `Lead`
- `actions/crm/lead_mark_lead_lost.go`: user-owned Action implementation
- `actions/crm/lead_mark_lead_lost_test.go`: user-owned Action tests


Do not load or import Runtime internals, database handles, registries, workers, or unrelated generated domain files for this Action.
