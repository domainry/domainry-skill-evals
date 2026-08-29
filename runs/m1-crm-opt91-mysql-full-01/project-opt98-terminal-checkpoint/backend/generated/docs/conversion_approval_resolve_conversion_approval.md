# Action conversion_approval.resolve_conversion_approval

Project-owned implementation of 处理转化审批

This file is generated. Implement business logic only in `actions/crm/conversion_approval_resolve_conversion_approval.go` and tests in `actions/crm/conversion_approval_resolve_conversion_approval_test.go`. The machine-readable scope is `generated/context/conversion_approval_resolve_conversion_approval.json`.

## Typed input

- `comment` (`long_text`, optional): 审批意见
- `expected_updated_at` (`datetime`, optional): 预期版本
- `request_id` (`text`, required): 请求 ID
- `resolution` (`value_domain`, required): 审批结果


## Typed output

- `approval_id` (`object_id`, required): 审批 ID
- `customer_id` (`object_id`, optional): 客户 ID
- `lead_id` (`object_id`, required): 线索 ID
- `resolution` (`value_domain`, required): 审批结果


## Authorized objects

- `conversion_approval`: operations `conditional_update`, `get_for_update`; types `generated/schema/conversion_approval.gen.go`; data API `generated/data/conversion_approval.gen.go`
- `customer`: operations `create`; types `generated/schema/customer.gen.go`; data API `generated/data/customer.gen.go`
- `lead`: operations `conditional_update`, `get_for_update`; types `generated/schema/lead.gen.go`; data API `generated/data/lead.gen.go`


## Authorized Connector operations

- No Connector capabilities.


## Authorized notification operations

- notification.intent.dispatch event_type=lead.conversion_approved via capabilities.Notifications.Dispatch or bounded DispatchBatch (1..200)
- notification.intent.dispatch event_type=lead.conversion_rejected via capabilities.Notifications.Dispatch or bounded DispatchBatch (1..200)


## Authorized file operations

- No file capability.


## Bounded batch contract

Authorized generated `*Batch` methods accept 1 through 200 inputs. Query and receipt results preserve input order and correspond one-to-one with inputs. A batch error returns no result slice. Reads may already have completed before a later read fails, but have no write effect. Mutations and notification intents remain staged inside this Action's single Runtime-owned transaction and commit together only after the Handler succeeds; project code must return any batch error. Every item inherits the invocation's Workspace, Principal, authorization grant, and data Scope. Notification source-event and dedupe identities remain required per item.

## Read order

- `generated/docs/conversion_approval_resolve_conversion_approval.md`: focused Action contract and authorized domain surface
- `generated/capabilities/conversion_approval_resolve_conversion_approval.gen.go`: typed Handler input, output, errors, and minimum capabilities; focus symbols: `ResolveConversionApprovalInput`, `ResolveConversionApprovalOutput`, `ResolveConversionApprovalCapabilities`
- `generated/schema/conversion_approval.gen.go`: authorized object types and field contracts; focus symbols: `ConversionApproval`
- `generated/schema/customer.gen.go`: authorized object types and field contracts; focus symbols: `Customer`
- `generated/schema/lead.gen.go`: authorized object types and field contracts; focus symbols: `Lead`
- `actions/crm/conversion_approval_resolve_conversion_approval.go`: user-owned Action implementation
- `actions/crm/conversion_approval_resolve_conversion_approval_test.go`: user-owned Action tests


Do not load or import Runtime internals, database handles, registries, workers, or unrelated generated domain files for this Action.
