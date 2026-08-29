package crm

import (
	"context"
	"time"

	capabilities "example.com/domainry/m1-sales-crm/generated/capabilities"
	"example.com/domainry/m1-sales-crm/generated/data"
	"example.com/domainry/m1-sales-crm/generated/schema"
)

func testPrincipal(userID string) capabilities.Principal {
	return capabilities.Principal{UserID: userID, RoleKey: "sales_rep", DepartmentID: "east", SurfaceKey: "business_workspace", Known: true}
}

type testCreateExecution struct{ principal capabilities.Principal }

func (e testCreateExecution) Principal() capabilities.Principal { return e.principal }

type testLeadExecution struct {
	principal capabilities.Principal
	target    schema.LeadID
}

func (e testLeadExecution) Principal() capabilities.Principal { return e.principal }
func (e testLeadExecution) TargetID() schema.LeadID           { return e.target }

type testApprovalExecution struct {
	principal capabilities.Principal
	target    schema.ConversionApprovalID
}

func (e testApprovalExecution) Principal() capabilities.Principal     { return e.principal }
func (e testApprovalExecution) TargetID() schema.ConversionApprovalID { return e.target }

type testLeadStore struct {
	record      schema.Lead
	created     schema.Lead
	updated     schema.Lead
	listed      []schema.Lead
	createCalls int
	updateCalls int
	listCalls   int
	lockCalls   int
}

func (s *testLeadStore) Create(_ context.Context, _ schema.CreateLead) (schema.Lead, error) {
	s.createCalls++
	return s.created, nil
}
func (s *testLeadStore) CreateBatch(_ context.Context, _ []schema.CreateLead) ([]schema.Lead, error) {
	return nil, nil
}
func (s *testLeadStore) GetForUpdate(_ context.Context, _ schema.LeadID) (schema.Lead, error) {
	return s.record, nil
}
func (s *testLeadStore) GetForUpdateBatch(_ context.Context, _ []schema.LeadID) ([]schema.Lead, error) {
	s.lockCalls++
	if s.record.ID != "" {
		return []schema.Lead{s.record}, nil
	}
	return s.listed, nil
}
func (s *testLeadStore) ConditionalUpdate(_ context.Context, _ data.LeadUpdateMutation) (schema.Lead, error) {
	s.updateCalls++
	return s.updated, nil
}
func (s *testLeadStore) ConditionalUpdateBatch(_ context.Context, _ []data.LeadUpdateMutation) ([]schema.Lead, error) {
	return []schema.Lead{s.updated}, nil
}
func (s *testLeadStore) List(_ context.Context, _ data.LeadQuery) ([]schema.Lead, error) {
	s.listCalls++
	if s.listCalls > 1 {
		return nil, nil
	}
	return s.listed, nil
}
func (s *testLeadStore) ListBatch(_ context.Context, _ []data.LeadQuery) ([][]schema.Lead, error) {
	return [][]schema.Lead{s.listed}, nil
}

type testCustomerStore struct {
	created     schema.Customer
	createCalls int
}

func (s *testCustomerStore) Create(_ context.Context, _ schema.CreateCustomer) (schema.Customer, error) {
	s.createCalls++
	return s.created, nil
}
func (s *testCustomerStore) CreateBatch(_ context.Context, _ []schema.CreateCustomer) ([]schema.Customer, error) {
	return []schema.Customer{s.created}, nil
}

type testApprovalStore struct {
	record      schema.ConversionApproval
	created     schema.ConversionApproval
	updated     schema.ConversionApproval
	createCalls int
	updateCalls int
}

func (s *testApprovalStore) Create(_ context.Context, _ schema.CreateConversionApproval) (schema.ConversionApproval, error) {
	s.createCalls++
	return s.created, nil
}
func (s *testApprovalStore) CreateBatch(_ context.Context, _ []schema.CreateConversionApproval) ([]schema.ConversionApproval, error) {
	return []schema.ConversionApproval{s.created}, nil
}
func (s *testApprovalStore) GetForUpdate(_ context.Context, _ schema.ConversionApprovalID) (schema.ConversionApproval, error) {
	return s.record, nil
}
func (s *testApprovalStore) GetForUpdateBatch(_ context.Context, _ []schema.ConversionApprovalID) ([]schema.ConversionApproval, error) {
	return []schema.ConversionApproval{s.record}, nil
}
func (s *testApprovalStore) ConditionalUpdate(_ context.Context, _ data.ConversionApprovalUpdateMutation) (schema.ConversionApproval, error) {
	s.updateCalls++
	return s.updated, nil
}
func (s *testApprovalStore) ConditionalUpdateBatch(_ context.Context, _ []data.ConversionApprovalUpdateMutation) ([]schema.ConversionApproval, error) {
	return []schema.ConversionApproval{s.updated}, nil
}

type testReminderStore struct {
	exists      bool
	createCalls int
	updateCalls int
}

func (s *testReminderStore) Exists(_ context.Context, _ data.LeadReminderDeliveryQuery) (bool, error) {
	return s.exists, nil
}
func (s *testReminderStore) ExistsBatch(_ context.Context, _ []data.LeadReminderDeliveryQuery) ([]bool, error) {
	return []bool{s.exists}, nil
}
func (s *testReminderStore) List(_ context.Context, _ data.LeadReminderDeliveryQuery) ([]schema.LeadReminderDelivery, error) {
	if !s.exists {
		return nil, nil
	}
	return []schema.LeadReminderDelivery{{ID: "delivery-1", DedupeKey: "stale:lead-1:2026-08-24", UpdatedAt: "revision-1"}}, nil
}
func (s *testReminderStore) ListBatch(_ context.Context, _ []data.LeadReminderDeliveryQuery) ([][]schema.LeadReminderDelivery, error) {
	rows, _ := s.List(context.Background(), data.LeadReminderDeliveryQuery{})
	return [][]schema.LeadReminderDelivery{rows}, nil
}
func (s *testReminderStore) Create(_ context.Context, input schema.CreateLeadReminderDelivery) (schema.LeadReminderDelivery, error) {
	s.createCalls++
	return schema.LeadReminderDelivery{ID: "delivery-1", DedupeKey: input.DedupeKey}, nil
}
func (s *testReminderStore) CreateBatch(_ context.Context, inputs []schema.CreateLeadReminderDelivery) ([]schema.LeadReminderDelivery, error) {
	s.createCalls += len(inputs)
	return make([]schema.LeadReminderDelivery, len(inputs)), nil
}
func (s *testReminderStore) ConditionalUpdate(_ context.Context, _ data.LeadReminderDeliveryUpdateMutation) (schema.LeadReminderDelivery, error) {
	s.updateCalls++
	return schema.LeadReminderDelivery{ID: "delivery-1"}, nil
}
func (s *testReminderStore) ConditionalUpdateBatch(_ context.Context, inputs []data.LeadReminderDeliveryUpdateMutation) ([]schema.LeadReminderDelivery, error) {
	s.updateCalls += len(inputs)
	return make([]schema.LeadReminderDelivery, len(inputs)), nil
}

type testApprovalNotifications struct {
	calls int
	last  capabilities.ResolveConversionApprovalNotificationIntent
}

func (s *testApprovalNotifications) Dispatch(_ context.Context, input capabilities.ResolveConversionApprovalNotificationIntent) (string, error) {
	s.calls++
	s.last = input
	return "notification-1", nil
}
func (s *testApprovalNotifications) DispatchBatch(_ context.Context, _ []capabilities.ResolveConversionApprovalNotificationIntent) ([]string, error) {
	return nil, nil
}

type testReminderNotifications struct {
	calls int
	last  capabilities.ProcessStaleLeadRemindersNotificationIntent
}

func (s *testReminderNotifications) Dispatch(_ context.Context, input capabilities.ProcessStaleLeadRemindersNotificationIntent) (string, error) {
	s.calls++
	s.last = input
	return "notification-1", nil
}
func (s *testReminderNotifications) DispatchBatch(_ context.Context, inputs []capabilities.ProcessStaleLeadRemindersNotificationIntent) ([]string, error) {
	s.calls += len(inputs)
	if len(inputs) > 0 {
		s.last = inputs[0]
	}
	return make([]string, len(inputs)), nil
}

type testAuditStore struct {
	created schema.ReportExportAudit
	calls   int
}

func (s *testAuditStore) Create(_ context.Context, _ schema.CreateReportExportAudit) (schema.ReportExportAudit, error) {
	s.calls++
	return s.created, nil
}
func (s *testAuditStore) CreateBatch(_ context.Context, _ []schema.CreateReportExportAudit) ([]schema.ReportExportAudit, error) {
	return []schema.ReportExportAudit{s.created}, nil
}

func ownedLead(status schema.LeadStatus, amount string) schema.Lead {
	owner := "east_sales"
	statusChangedAt := time.Date(2026, 8, 1, 0, 0, 0, 0, time.UTC)
	return schema.Lead{ID: "lead-1", UpdatedAt: "revision-1", CompanyName: "Acme", ExpectedAmount: schema.LeadExpectedAmount(amount), OwnerUser: &owner, Source: schema.LeadSourceWebsite, Status: status, StatusChangedAt: &statusChangedAt}
}
