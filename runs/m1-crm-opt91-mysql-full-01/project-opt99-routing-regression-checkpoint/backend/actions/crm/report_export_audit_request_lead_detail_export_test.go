package crm

import (
	capabilities "example.com/domainry/m1-sales-crm/generated/capabilities"
	"example.com/domainry/m1-sales-crm/generated/schema"
	"testing"
)

func TestRequestLeadDetailExportCreatesRequesterAudit(t *testing.T) {
	store := &testAuditStore{created: schema.ReportExportAudit{ID: "audit-1", Status: schema.ReportExportAuditStatusRequested}}
	director := testPrincipal("sales_director")
	director.RoleKey = "sales_director"
	out, err := RequestLeadDetailExport(t.Context(), capabilities.RequestLeadDetailExportCapabilities{Execution: testCreateExecution{director}, ReportExportAudit: store}, capabilities.RequestLeadDetailExportInput{RequestID: "export-1", Reason: "quarterly review"})
	if err != nil || out.AuditID != "audit-1" || out.Status != schema.ReportExportAuditRequestLeadDetailExportStatusRequested || store.calls != 1 {
		t.Fatalf("export audit mismatch: out=%+v calls=%d err=%v", out, store.calls, err)
	}
}
