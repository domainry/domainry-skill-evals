// This file is initial project-owned business source. Domainry will never overwrite it.
package crm

import (
	"context"
	capabilities "example.com/domainry/m1-sales-crm/generated/capabilities"
	"example.com/domainry/m1-sales-crm/generated/schema"
	"strings"
)

// RequestLeadDetailExport implements the project-owned report_export_audit.request_lead_detail_export Handler.
func RequestLeadDetailExport(ctx context.Context, caps capabilities.RequestLeadDetailExportCapabilities, input capabilities.RequestLeadDetailExportInput) (capabilities.RequestLeadDetailExportOutput, error) {
	if caps.Execution == nil || caps.ReportExportAudit == nil {
		return capabilities.RequestLeadDetailExportOutput{}, businessError("report_export.capability_required", "export audit capabilities are unavailable")
	}
	principal := caps.Execution.Principal()
	if err := requirePrincipal(principal); err != nil {
		return capabilities.RequestLeadDetailExportOutput{}, err
	}
	if strings.TrimSpace(input.Reason) == "" {
		return capabilities.RequestLeadDetailExportOutput{}, businessError("report_export.reason_required", "an export reason is required")
	}
	audit, err := caps.ReportExportAudit.Create(ctx, schema.CreateReportExportAudit{
		ReportKey: "lead_detail_export", RequestReason: input.Reason, RequestedBy: principal.UserID,
		Status: schema.ReportExportAuditStatusRequested,
	})
	if err != nil {
		return capabilities.RequestLeadDetailExportOutput{}, err
	}
	return capabilities.RequestLeadDetailExportOutput{AuditID: audit.ID, Status: schema.ReportExportAuditRequestLeadDetailExportStatusRequested}, nil
}
