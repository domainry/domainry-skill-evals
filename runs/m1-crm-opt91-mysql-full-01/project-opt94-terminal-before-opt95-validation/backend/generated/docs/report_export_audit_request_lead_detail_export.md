# Action report_export_audit.request_lead_detail_export

Project-owned implementation of 申请线索明细导出

This file is generated. Implement business logic only in `actions/crm/report_export_audit_request_lead_detail_export.go` and tests in `actions/crm/report_export_audit_request_lead_detail_export_test.go`. The machine-readable scope is `generated/context/report_export_audit_request_lead_detail_export.json`.

## Typed input

- `reason` (`text`, required): 导出原因
- `request_id` (`text`, required): 请求 ID


## Typed output

- `audit_id` (`object_id`, required): 导出审计 ID
- `status` (`value_domain`, required): 状态


## Authorized objects

- `report_export_audit`: operations `create`; types `generated/schema/report_export_audit.gen.go`; data API `generated/data/report_export_audit.gen.go`


## Authorized Connector operations

- No Connector capabilities.


## Authorized notification operations

- No notification dispatch capability.


## Authorized file operations

- No file capability.


## Bounded batch contract

Authorized generated `*Batch` methods accept 1 through 200 inputs. Query and receipt results preserve input order and correspond one-to-one with inputs. A batch error returns no result slice. Reads may already have completed before a later read fails, but have no write effect. Mutations and notification intents remain staged inside this Action's single Runtime-owned transaction and commit together only after the Handler succeeds; project code must return any batch error. Every item inherits the invocation's Workspace, Principal, authorization grant, and data Scope. Notification source-event and dedupe identities remain required per item.

## Read order

- `generated/docs/report_export_audit_request_lead_detail_export.md`: focused Action contract and authorized domain surface
- `generated/capabilities/report_export_audit_request_lead_detail_export.gen.go`: typed Handler input, output, errors, and minimum capabilities; focus symbols: `RequestLeadDetailExportInput`, `RequestLeadDetailExportOutput`, `RequestLeadDetailExportCapabilities`
- `generated/schema/report_export_audit.gen.go`: authorized object types and field contracts; focus symbols: `ReportExportAudit`
- `actions/crm/report_export_audit_request_lead_detail_export.go`: user-owned Action implementation
- `actions/crm/report_export_audit_request_lead_detail_export_test.go`: user-owned Action tests


Do not load or import Runtime internals, database handles, registries, workers, or unrelated generated domain files for this Action.
