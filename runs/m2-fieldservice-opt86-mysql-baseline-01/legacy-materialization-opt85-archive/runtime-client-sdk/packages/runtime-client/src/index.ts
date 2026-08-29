import type { RuntimeProductSurface } from './surface-contract'

export interface RuntimeUser {
  id: string
  name: string
  email: string
  phone?: string
  department_id: string
  department_path: string
  status: 'active' | 'disabled'
}

export interface RuntimeRole {
  id: string
  key: string
  label: string
}

export interface RuntimeSession {
  username: string
  displayName: string
  loginAt: string
  roleId: string
  accessToken: string
  refreshToken: string
  expiresAt: string
  remember: boolean
  user: RuntimeUser
  roles: RuntimeRole[]
  permissions: string[]
}

export interface RuntimeAuthResponse {
  access_token: string
  refresh_token: string
  token_type: string
  expires_at: string
  user: RuntimeUser
  roles: RuntimeRole[]
  default_role: string
  must_change_password: boolean
}

export interface RuntimeAuthMeResponse {
  user: RuntimeUser
  roles: RuntimeRole[]
  default_role: string
  permissions: string[]
}

export interface RuntimeSessionRevocationResponse {
  revoked_sessions: number
  current_session_id?: string
}

export interface RuntimeAuthProvider {
  key: string
  label: string
  type: string
  enabled: boolean
}

export interface RuntimeAuthProviderStartResponse {
  provider: string
  state: string
  code?: string
  expires_at: string
}

export interface RuntimeErrorPayload {
  error?: string
  message?: string
  detail?: string
  code?: string
  message_key?: string
  field_path?: string
  params?: Record<string, string>
  capability_key?: string
  contract_version?: string
  request_id?: string
  [key: string]: unknown
}

export const RUNTIME_DOMAIN_API_CONTRACT_VERSION = 'runtime-domain-api-v1'
export const RUNTIME_DOMAIN_API_CONTRACT_HASH =
  'fdde97e582d83dd3bdec714e1f1a1f04009866db3689f6e75764f9daa194ef2b'

export type RuntimeErrorCategory =
  | 'permission_denied'
  | 'data_scope_hidden'
  | 'not_found'
  | 'concurrency_conflict'
  | 'business_error'
  | 'transport_error'

export interface RuntimeRecord<TData extends Record<string, unknown> = Record<string, unknown>> {
  id: string
  data: TData
  created_at?: string
  updated_at?: string
}

export interface RuntimeRecordPage<TData extends Record<string, unknown> = Record<string, unknown>> {
  items: RuntimeRecord<TData>[]
  page: number
  page_size: number
  total: number
  has_next: boolean
}

export interface RuntimeRecordQuery {
  page?: number
  pageSize?: number
  search?: string
  view?: string
  filters?: Record<string, unknown>
  sort?: Array<{ field: string; direction?: 'asc' | 'desc' }>
}

export interface RuntimeWorkforceProfile {
  id: string
  organization_id: string
  identity_user_id: string
  worker_no: string
  worker_type: 'employee' | 'contractor' | 'partner_staff' | 'temporary'
  work_status: 'pending' | 'active' | 'suspended' | 'terminated'
  start_date?: string
  end_date?: string
  primary_assignment_id?: string
  version: number
}

export interface RuntimeIdentityAccount {
  id: string
  name: string
  email: string
  phone?: string
  status: 'active' | 'disabled' | 'deleted'
  version: number
  created_at: string
  updated_at: string
}

export interface RuntimeWorkforceAssignment {
  id: string
  workforce_profile_id: string
  organization_unit_id: string
  position_id?: string
  manager_workforce_profile_id?: string
  assignment_type: 'primary' | 'secondary' | 'temporary' | 'acting'
  effective_from?: string
  effective_to?: string
  status: 'active' | 'disabled' | 'deleted'
  version: number
}

export interface RuntimeDepartment {
  id: string
  name: string
  parent_id?: string
  leader_workforce_profile_id?: string
  path: string
  ancestor_ids: string[]
  depth: number
  sort_order: number
  status?: 'active' | 'disabled' | 'deleted'
}

export interface RuntimeWorkforcePosition {
  id: string
  code: string
  name: string
}

export interface RuntimeWorkforceManager {
  workforce_profile_id: string
  identity_user_id: string
  display_name: string
}

export interface RuntimeWorkforceRole {
  id: string
  key: string
  label: string
}

export interface RuntimeWorkforceApplicationItem {
  profile: RuntimeWorkforceProfile
  display_name: string
  roles: RuntimeWorkforceRole[]
  email?: string
  phone?: string
  updated_at?: string
  primary_assignment?: RuntimeWorkforceAssignment
  department?: RuntimeDepartment
  position?: RuntimeWorkforcePosition
  manager?: RuntimeWorkforceManager
}

export interface RuntimeWorkforceApplicationPage {
  items: RuntimeWorkforceApplicationItem[]
  page: number
  page_size: number
  total: number
  has_next: boolean
}

export interface RuntimeWorkforceQuery {
  page?: number
  pageSize?: number
  search?: string
  departmentId?: string
  workStatus?: RuntimeWorkforceProfile['work_status']
}

export interface RuntimeWorkforceOnboardingRequest {
  user: RuntimeIdentityAccount
  profile: RuntimeWorkforceProfile
  assignment: RuntimeWorkforceAssignment
  role_ids?: string[]
  reason?: string
}

export interface RuntimeWorkforceOnboardingResult {
  user: RuntimeIdentityAccount
  profile: RuntimeWorkforceProfile
  assignment: RuntimeWorkforceAssignment
  role_assignments: Array<Record<string, unknown>>
}

export interface RuntimeWorkforceLifecycleRequest {
  operation: 'invite' | 'onboard' | 'assign' | 'transfer' | 'add_secondary' | 'suspend' | 'revoke_access'
  profile: RuntimeWorkforceProfile
  assignment?: RuntimeWorkforceAssignment
  previous_assignment_id?: string
  effective_at?: string
  reason?: string
}

export interface RuntimeWorkforceLifecycleResult {
  profile?: RuntimeWorkforceProfile
  assignments?: RuntimeWorkforceAssignment[]
  ended_assignment_count: number
  revoked_entitlement_count: number
}

export interface RuntimeWorkforceTransferItem {
  profile_id: string
  previous_assignment_id: string
  assignment: RuntimeWorkforceAssignment
  effective_at: string
  reason?: string
}

export interface RuntimeWorkforceTransferReceipt {
  id: string
  workspace_id: string
  actor_id: string
  idempotency_key: string
  request_fingerprint: string
  items: RuntimeWorkforceTransferItem[]
  replayed?: boolean
  created_at: string
}

export interface RuntimeWorkforceTerminationRequest {
  effective_at: string
  reason: string
  task_transfer_user_id?: string
}

export interface RuntimeWorkforceRehireRequest {
  effective_at: string
  assignment: RuntimeWorkforceAssignment
  reason: string
}

export interface RuntimeEffectiveMenu {
  id: string
  key: string
  label: string
  description?: string
  route?: string
  icon?: string
  parent_id?: string
  sort_order: number
  status: 'active' | 'disabled' | 'deleted'
}

export interface RuntimeAuthoringResult<T> {
  resource: T
  resource_hash: string
  snapshot_hash: string
  available_successors?: Array<Record<string, unknown>>
}

function runtimeAuthoringResource<T>(value: T | RuntimeAuthoringResult<T>): T {
  if (typeof value === 'object' && value !== null && 'resource' in value) {
    return (value as RuntimeAuthoringResult<T>).resource
  }
  return value as T
}

export interface RuntimeJobCatalogItem {
  id: string
  code: string
  name: string
  family?: string
  level?: string
  description?: string
  status: string
}

export interface RuntimePosition {
  id: string
  code: string
  name: string
  job_catalog_item_id: string
  organization_unit_id?: string
  headcount: number
  effective_from?: string
  effective_to?: string
  status: string
}

export interface RuntimeMutationOptions {
  idempotencyKey?: string
  expectedUpdatedAt?: string
  requestId?: string
}

export type RuntimeFileScanStatus = 'pending' | 'clean' | 'quarantined' | 'failed'
export interface RuntimeUploadedFile {
  file_id: string
  content_sha256: string
  scan_status: RuntimeFileScanStatus
  url: string
  filename: string
  content_type: string
  size: number
  object_key?: string
  field_key?: string
}
export interface RuntimeFileScanEvidence {
  file_id: string
  content_sha256: string
  size: number
  status: RuntimeFileScanStatus
  provider?: string
  evidence_ref?: string
  scanned_at?: string
  scan_receipt?: string
}

export interface RuntimeFileDownloadOptions {
  objectKey: string
  fieldKey: string
  recordId?: string
  requestId?: string
}

export interface RuntimeActionOptions extends RuntimeMutationOptions {
  assuranceToken?: string
}

export type RuntimeActionKind =
  | 'object_create'
  | 'object_operation'
  | 'bulk_operation'
  | 'record_update'
  | 'record_delete'
  | 'record_restore'
  | 'transition_state'
  | 'conditional_update'
  | 'record_operation'

export interface RuntimeActionDefinition {
  key: string
  object_key: string
  label: string
  kind: RuntimeActionKind
  requires_permission: string
  preconditions: string[]
  audit_event: string
  risk_level?: string
  input_type?: string
  output_type?: string
  payload_fields?: Array<Record<string, unknown>>
  idempotency_keys?: string[]
  optimistic_concurrency?: boolean
  concurrency_field?: string
}

export function runtimeActionInvocationScope(
  action: Pick<RuntimeActionDefinition, 'kind'>,
): 'object' | 'record' {
  switch (action.kind) {
    case 'object_create':
    case 'object_operation':
    case 'bulk_operation':
      return 'object'
    default:
      return 'record'
  }
}

export interface RuntimeActionRecordRef {
  object_key: string
  record_id: string
}

export interface RuntimeTriggeredWorkflow {
  [key: string]: unknown
}

export type RuntimeWorkflowProcessStatus =
  | 'running'
  | 'waiting'
  | 'completed'
  | 'rejected'
  | 'cancelled'
  | 'failed'
  | 'configuration_error'
  | 'resolved'

export interface RuntimeWorkflowProcess {
  id: string
  workflow_key: string
  workflow_name: string
  object_key?: string
  record_id?: string
  initiator_id: string
  status: RuntimeWorkflowProcessStatus | string
  current_node_names?: string[]
  business_outcome?: string
  created_at: string
  updated_at: string
  completed_at?: string
}

export interface RuntimeWorkflowTask {
  id: string
  process_id: string
  node_instance_id: string
  node_id: string
  title: string
  assignee_user_id?: string
  assignee_name?: string
  assignee_role_key?: string
  sequence: number
  status: string
  decision?: string
  comment?: string
  due_at?: string
  completed_by?: string
  completed_at?: string
  created_at: string
  updated_at: string
}

export interface RuntimeWorkflowNode {
  id: string
  node_id: string
  name: string
  node_type: string
  action_key?: string
  iteration: number
  status: string
  error_code?: string
  started_at: string
  completed_at?: string
}

export interface RuntimeWorkflowEvent {
  id: string
  node_id?: string
  task_id?: string
  event: string
  actor_id?: string
  summary?: string
  created_at: string
}

export interface RuntimeWorkflowProcessDetail {
  process: RuntimeWorkflowProcess
  nodes: RuntimeWorkflowNode[]
  tasks: RuntimeWorkflowTask[]
  events: RuntimeWorkflowEvent[]
}

export interface RuntimeWorkflowRunResult {
  workflow_key: string
  name: string
  status: string
  process_id?: string
}

export interface RuntimeIntegrationIntentResult {
  id: string
  connector_key: string
  provider_key?: string
  connection_key?: string
  operation: string
  status: string
  response_ref?: string
  response?: Record<string, unknown>
  error?: string
  attempt_count: number
  created_at?: string
  updated_at?: string
}

export interface RuntimeWorkflowProcessQuery {
  resourceId?: string
  workflowKey?: string
  definitionVersion?: number
  objectKey?: string
  recordId?: string
  statuses?: readonly string[]
  initiatorId?: string
  approverId?: string
  updatedFrom?: string
  updatedTo?: string
  limit?: number
}

export interface RuntimeBusinessAuditEvent {
  id: string
  workspace_id: string
  event: string
  object_key?: string
  record_id?: string
  actor_id: string
  role_key: string
  summary: string
  metadata?: Record<string, unknown>
  before?: Record<string, unknown>
  after?: Record<string, unknown>
  created_at: string
}

export interface RuntimeBusinessAuditPage {
  items: RuntimeBusinessAuditEvent[]
  count: number
  retention_class: string
  retention_days: number
}

export interface RuntimeBusinessAuditQuery {
  objectKey?: string
  recordId?: string
  event?: string
  actorId?: string
  roleKey?: string
  requestId?: string
  createdFrom?: string
  createdTo?: string
  limit?: number
}

export interface RuntimeBusinessAuditExportFilter {
  event?: string
  object_key?: string
  record_id?: string
  actor_id?: string
  role_key?: string
  result?: string
  created_from?: string
  created_to?: string
}

export interface RuntimeBusinessAuditExportRequest {
  filters: RuntimeBusinessAuditExportFilter
  format?: 'csv'
}

export interface RuntimeBusinessAuditExportPrepared {
  id: string
  report_source: 'business_audit_events'
  filename: string
  content_sha256: string
  row_count: number
  audit_identity: string
  scope_sha256: string
  filters: RuntimeBusinessAuditExportFilter
  download_token: string
  expires_at: string
}

export interface RuntimeWorkflowTaskQuery {
  status?: string
  limit?: number
}

export type RuntimeWorkflowTaskDecision = 'approved' | 'rejected' | 'returned'

export type RuntimeAgentRouteType = 'interactive_query' | 'agent_task' | 'workflow' | 'proposal'
export type RuntimeAgentInteractiveRunStatus = 'running' | 'completed' | 'handed_off' | 'failed' | 'cancelled'

export interface RuntimeAgentContext {
  entrypoint_key: string
  route_key: string
  object_key?: string
  record_id?: string
  selected_record_ids?: string[]
  locale?: string
  timezone?: string
}

export interface RuntimeAgentInteractiveRunRequest {
  message: string
  context: RuntimeAgentContext
  response_mode?: 'blocking'
  timeout_seconds?: number
  new_session?: boolean
  external_session_id?: string
  metadata?: Record<string, unknown>
}

export interface RuntimeAgentInteractiveRun {
  id: string
  workspace_id: string
  session_id: string
  user_id: string
  role_key: string
  agent_key: string
  entrypoint_key: string
  context_revision: string
  surface: RuntimeProductSurface
  route_key: string
  object_key?: string
  record_id?: string
  status: RuntimeAgentInteractiveRunStatus | string
  structured_result?: Record<string, unknown>
  route_type?: RuntimeAgentRouteType
  routed_target_key?: string
  task_run_id?: string
  workflow_process_id?: string
  external_run_id?: string
  model?: string
  usage?: Record<string, unknown>
  proposal_id?: string
  tool_call_count: number
  tool_invocations?: Record<string, unknown>[]
  authorization: Record<string, unknown>
  error_code?: string
  idempotency_key: string
  revision: number
  created_at: string
  updated_at: string
  completed_at?: string
}

export interface RuntimeAgentInteractiveExecutionResult {
  run: RuntimeAgentInteractiveRun
  result: Record<string, unknown>
}

export interface RuntimeAgentStreamOptions {
  idempotencyKey: string
  requestId?: string
  signal?: AbortSignal
  onAccepted?: (value: Record<string, unknown>) => void
  /** Maximum reconnects after a transport EOF/failure before a terminal event. */
  maxReconnectAttempts?: number
  reconnectDelayMs?: number
}

export interface RuntimeAgentAnalysisRequest {
  intent: string
  sql?: string
  metric_spec?: Record<string, unknown>
  dry_run?: boolean
  max_rows?: number
}

export interface RuntimeAgentAnalysisResult {
  query_ref: string
  status: string
  execution_mode: string
  scope_note: string
  workspace_id: string
  role: string
  truncated: boolean
  audit_event_key: string
  report_center_ref?: string
  object_key?: string
  report_key?: string
  rows?: Array<Record<string, unknown>>
  row_count?: number
  total?: number
  masked_fields?: string[]
  report_governance?: Record<string, unknown>
  report_provenance?: Record<string, unknown>
}

export interface RuntimeAgentReportState {
  query_ref: string
  status: string
  created_at: number
  [key: string]: unknown
}

export interface RuntimeAgentReportHandoff {
  query_ref: string
  status: 'prepared_for_report_center' | string
  handoff: string
  report_query_run: RuntimeAgentReportState
  report_export_audit: RuntimeAgentReportState
  download_task: RuntimeAgentReportState
  scope: string
  next_step: string
}

export interface RuntimeAgentTaskRun {
  id: string
  process_id?: string
  node_instance_id?: string
  interactive_run_id?: string
  task_key: string
  task_version: string
  status: string
  outcome?: string
  proposal_id?: string
  error_code?: string
  reconciliation_required: boolean
  reconciliation_state?: string
  identity: {
    mode: 'inherit' | 'service'
    execution_user_id: string
    execution_role_key: string
    service_principal_key?: string
  }
  output?: Record<string, unknown>
  action_receipts?: string[]
  audit_refs?: string[]
  attempt: number
  max_attempts: number
  revision: number
  created_at: string
  updated_at: string
}

export interface RuntimeAgentSession {
  external_session_id: string
  agent_session_id?: string
  title: string
  last_summary?: string
  mode?: string
  workspace_id?: string
  surface?: string
  object_key?: string
  record_id?: string
  user_id?: string
  role?: string
  archived: boolean
  context?: Record<string, unknown>
  created_at: number
  updated_at: number
}

export interface RuntimeAgentSessionQuery {
  search?: string
  surface?: string
  objectKey?: string
  recordId?: string
  includeArchived?: boolean
  limit?: number
}

export interface RuntimeAgentSessionUpsertRequest {
  external_session_id?: string
  agent_session_id?: string
  title?: string
  last_summary?: string
  mode?: string
  context?: Record<string, unknown>
  archived?: boolean
}

export interface RuntimeAgentProposal {
  proposal_id: string
  status: string
  title?: string
  summary?: string
  source?: string
  reference?: string
  actor?: string
  workspace_id?: string
  user_id?: string
  role?: string
  proposed?: Record<string, unknown>
  metadata?: Record<string, unknown>
  execution?: Record<string, unknown>
  decision_reason?: string
  decision_actor?: string
  created_at: number
  updated_at: number
  decided_at?: number
  audited: boolean
}

export interface RuntimeRecordActionResult<
  TRecordData extends Record<string, unknown> = Record<string, unknown>,
  TOutput = unknown,
> {
  action_key: string
  object_key: string
  record_id: string
  message: string
  record: RuntimeRecord<TRecordData>
  output?: TOutput
  created_records?: RuntimeActionRecordRef[]
  updated_records?: RuntimeActionRecordRef[]
  deleted_records?: RuntimeActionRecordRef[]
  restored_records?: RuntimeActionRecordRef[]
  triggered_workflows: RuntimeTriggeredWorkflow[]
}

export interface RuntimeObjectActionResult<TOutput = unknown> {
  action_key: string
  object_key: string
  status: string
  message?: string
  output?: TOutput
  created_records?: RuntimeActionRecordRef[]
  updated_records?: RuntimeActionRecordRef[]
  deleted_records?: RuntimeActionRecordRef[]
  restored_records?: RuntimeActionRecordRef[]
  triggered_workflows?: RuntimeTriggeredWorkflow[]
}

export type RuntimeActionResult<TOutput = unknown> =
  | RuntimeObjectActionResult<TOutput>
  | RuntimeRecordActionResult<Record<string, unknown>, TOutput>

export interface RuntimeReportRow {
  dimensions?: Record<string, string>
  measures?: Record<string, string>
}

export type RuntimeReportObjectSQLParameterValue = string | number | boolean | null

export interface RuntimeReportResultColumn {
  key: string
  type: string
  kind: 'dimension' | 'measure'
  precision?: number
  scale?: number
}

export interface RuntimeReportAnalysis {
  key: string
  type: string
  rows: RuntimeReportRow[]
}

export interface RuntimeReportSnapshotFreshness {
  snapshot_id: string
  watermark: string
  source_versions: Record<string, string>
  refreshed_at: string
  lag_seconds: number
  stale: boolean
}

export interface RuntimeReportSummary {
  key: string
  name?: string
  rows: RuntimeReportRow[]
  row_count: number
  source_row_count: number
  analyses?: RuntimeReportAnalysis[]
  execution_mode: string
  result_schema?: RuntimeReportResultColumn[]
  snapshot?: RuntimeReportSnapshotFreshness
  page_size: number
  next_cursor?: string
  truncated: boolean
  total: number
  total_semantics: 'exact' | 'at_least'
}

export interface RuntimeReportPageOptions {
  pageSize?: number
  cursor?: string
}

export interface RuntimeReportSnapshot {
  id: string
  workspace_id: string
  report_key: string
  idempotency_key: string
  status: string
  summary?: RuntimeReportSummary
  watermark?: string
  source_versions?: Record<string, string>
  started_at: string
  refreshed_at?: string
  error_code?: string
}

export interface RuntimeReportExportFile {
  blob: Blob
  filename?: string
  artifact_id?: string
  content_sha256?: string
  download_token?: string
  row_count?: number
  expires_at?: string
}

export interface RuntimeReportExportDownload {
  id: string
  report_key: string
  object_key: string
  filename: string
  token: string
  expires_at: string
  content_sha256: string
  row_count: number
  scope: RuntimeReportExportScope
  watermarked: boolean
}

export type RuntimeReportExportStatus = 'accepted' | 'running' | 'completed' | 'failed' | 'cancelled'

export interface RuntimeReportExportJob {
  id: string
  batch_job_id: string
  audit_id: string
  report_key: string
  object_key: string
  status: RuntimeReportExportStatus
  pages_completed: number
  rows_exported: number
  total: number
  scope: RuntimeReportExportScope
  artifact_id?: string
  content_sha256?: string
  download_token?: string
  expires_at?: string
  error_code?: string
  created_at: string
  updated_at: string
}

export interface RuntimeReportExportFilter {
  dimension_key: string
  operator: 'eq' | 'ne' | 'gt' | 'gte' | 'lt' | 'lte' | 'in' | 'not_in' | 'between' | 'is_null' | 'not_null'
  values?: string[]
}

export interface RuntimeReportExportScope {
  /** Typed values for parameters declared by an object_sql_v1 Report. Unknown keys and invalid types fail closed. */
  parameters?: Record<string, RuntimeReportObjectSQLParameterValue>
  /** Stable Report dataset query predicate key; governed export also requires the Export Control allowlist. */
  query_key?: string
  analysis_key?: string
  filters?: RuntimeReportExportFilter[]
  date_range?: { dimension_key: string; from: string; to: string }
  timezone?: string
  /** Stable Report dataset tag predicate keys, canonicalized and combined with AND; governed export also requires the Export Control allowlist. */
  tags?: string[]
  /** Match mode selected from the report-owned tag allowlist. */
  tag_match?: 'any' | 'all'
  field_projection?: string[]
  purpose: string
  metric_definitions?: Array<{ key: string; version: string }>
  freshness: { mode: 'realtime' | 'snapshot'; snapshot_id?: string; maximum_lag_seconds?: number }
  role_key?: string
  data_scopes?: Record<string, string>
}

export type RuntimeNotificationMailbox = 'inbox' | 'unread' | 'action_required' | 'archived'
export type RuntimeNotificationScope = 'mine' | 'team'

export interface RuntimeNotificationFact { key: string; value: string }
export interface RuntimeNotificationAction {
  key: string
  kind: 'route' | 'business_action'
  label: string
  resource_type: string
  resource_id: string
  style?: 'primary' | 'secondary' | 'danger'
}
export interface RuntimeInboxNotification {
  id: string
  workspace_id: string
  recipient_user_id: string
  surface: RuntimeProductSurface
  event_id: string
  event_type: string
  source: string
  category: string
  severity: 'info' | 'warning' | 'critical'
  title: string
  body: string
  facts?: RuntimeNotificationFact[]
  actions?: RuntimeNotificationAction[]
  subject_type?: string
  subject_id?: string
  action_state: 'none' | 'open' | 'completed' | 'expired' | 'cancelled'
  alert_state?: 'firing' | 'acknowledged' | 'resolved'
  occurrence_count: number
  read_at?: string
  archived_at?: string
  expires_at?: string
  first_occurred_at: string
  last_occurred_at: string
  created_at: string
  updated_at: string
}
export interface RuntimeNotificationQuery {
  scope?: RuntimeNotificationScope
  teamMemberId?: string
  cursor?: string
  mailbox?: RuntimeNotificationMailbox
  query?: string
  categories?: readonly string[]
  sources?: readonly string[]
  severities?: readonly string[]
  actionStates?: readonly string[]
  from?: string
  to?: string
  limit?: number
}
export interface RuntimeNotificationPage {
  items: RuntimeInboxNotification[]
  next_cursor?: string
  has_more: boolean
}
export interface RuntimeNotificationFacet { key: string; count: number }
export interface RuntimeNotificationFacets {
  unread: number
  action_required: number
  categories: RuntimeNotificationFacet[]
  sources: RuntimeNotificationFacet[]
  severities: RuntimeNotificationFacet[]
}
export interface RuntimeNotificationSyncEvent {
  cursor: string
  unread: number
  updated_at?: string
}
export interface RuntimeNotificationSyncOptions {
  cursor?: string
  retryDelayMs?: number
  onError?: (error: unknown) => void
  /** Refetch the durable Inbox page/count after each SSE invalidation signal. */
  refetch?: (event: RuntimeNotificationSyncEvent) => void | Promise<void>
}
export interface RuntimeBusinessSyncEvent {
  cursor: string
  updated_at?: string
}
export interface RuntimeBusinessSyncOptions {
  cursor?: string
  retryDelayMs?: number
  onError?: (error: unknown) => void
  onStatus?: (status: 'connected' | 'reconnecting' | 'disconnected') => void
}
export type BusinessEventType = 'refresh' | 'resync'
export interface BusinessEvent {
  id: string
  type: BusinessEventType
  object_key?: string
  reason: string
  occurred_at: string
}
export type BusinessEventConnectionState = 'connecting' | 'open' | 'reconnecting' | 'closed'
export interface BusinessEventSubscriptionOptions {
  objectKeys?: readonly string[]
  eventTypes?: readonly Extract<BusinessEventType, 'refresh'>[]
  lastEventId?: string
  signal?: AbortSignal
  reconnect?: boolean
  initialRetryMs?: number
  maxRetryMs?: number
  onEvent: (event: BusinessEvent) => void
  onStateChange?: (state: BusinessEventConnectionState) => void
  onError?: (error: unknown) => void
}
export interface BusinessEventSubscription {
  close(): void
  readonly closed: Promise<void>
  lastEventId(): string
}
export interface RuntimeNotificationResolvedAction {
  key: string
  label: string
  style?: string
  navigation_kind: 'surface_route'
  route_key: string
  route_params: Record<string, string>
  status: 'available'
}
export interface RuntimeNotificationSavedView {
  key: string
  name: string
  mailbox: RuntimeNotificationMailbox
  scope: RuntimeNotificationScope
  team_member_id?: string
  query?: string
  categories?: string[]
  sources?: string[]
  severities?: string[]
  action_states?: string[]
  from?: string
  to?: string
}
export interface RuntimeNotificationPreference {
  recipient_key: string
  enabled_channels: Record<string, boolean>
  muted_template_keys?: string[]
  updated_at?: string
}

export interface RuntimeNotificationDelegation {
  id: string
  delegate_user_id: string
  starts_at?: string
  ends_at?: string
  categories?: string[]
  status?: string
  [key: string]: unknown
}

export interface RuntimeNotificationDelegatedOwner {
  user_id: string
  display_name?: string
  [key: string]: unknown
}

export interface RuntimeRecordImportIssue {
  field?: string
  message: string
  code?: string
  params?: Record<string, string>
  severity: string
}

export interface RuntimeRecordImportPreviewRow {
  row: number
  data: Record<string, unknown>
  raw_values?: Record<string, string>
  issues: RuntimeRecordImportIssue[]
  error_summary?: string
  valid: boolean
  duplicate: boolean
}

export interface RuntimeRecordImportPreview {
  object_key: string
  rows: RuntimeRecordImportPreviewRow[]
  error_rows?: RuntimeRecordImportPreviewRow[]
  valid_rows: number
  invalid_rows: number
  duplicate_rows: number
  can_apply: boolean
}

export interface RuntimeRecordImportApplyResult {
  object_key: string
  created: number
  skipped: number
  preview: RuntimeRecordImportPreview
}

export type RuntimeRecordBatchJobStatus = 'queued' | 'running' | 'completed' | 'failed' | 'cancelled' | 'quarantined'
export interface RuntimeRecordBatchJob {
  id: string
  workspace_id: string
  kind: 'import' | 'export' | string
  object_key: string
  status: RuntimeRecordBatchJobStatus | string
  checkpoint: number
  total: number
  result_filename?: string
  result_content_type?: string
  result_chunks?: number
  audit_id?: string
  result_artifact_id?: string
  error_code?: string
  attempt_count: number
  actor_id: string
  role_key: string
  created_at: string
  updated_at: string
}

export interface RuntimeBulkActionRequest {
  record_ids: string[]
  data?: Record<string, unknown>
  expected_versions?: Record<string, number>
}

export interface RuntimeBulkActionResult {
  action_key: string
  object_key: string
  total: number
  succeeded: number
  failed: number
  message: string
  items: Array<{ record_id: string; success: boolean; result?: RuntimeRecordActionResult; code?: string; error?: string }>
}

export interface RuntimeWebPushSubscription {
  id: string
  user_id: string
  endpoint_hash: string
  status: 'active' | 'revoked' | 'expired'
  expires_at?: string
  created_at: string
  updated_at: string
  revoked_at?: string
}

export interface RuntimeWebPushSubscriptionUpsertRequest {
  endpoint: string
  p256dh: string
  auth: string
  expires_at?: string
}

export interface RuntimeWebPushReadiness {
  ready: boolean
  public_key?: string
  connection_key?: string
  status: string
  reason?: 'connection_missing' | 'public_key_missing' | 'private_key_unbound' | 'private_key_unavailable' | 'connection_not_ready'
}
export interface RuntimeI18nResources {
  locale: string
  default_locale: string
  catalog_version: string
  resources: Record<string, string>
}

export class RuntimeApiError extends Error {
  constructor(
    public readonly status: number,
    public readonly payload: RuntimeErrorPayload,
    message: string,
  ) {
    super(message)
    this.name = 'RuntimeApiError'
  }

  get code() { return this.payload.code ?? '' }
  get messageKey() { return this.payload.message_key ?? this.payload.code ?? '' }
  get fieldPath() { return this.payload.field_path ?? '' }
  get params() { return this.payload.params ?? {} }
  get capabilityKey() { return this.payload.capability_key ?? '' }
  get contractVersion() { return this.payload.contract_version ?? '' }
  get requestId() { return this.payload.request_id ?? '' }

  get category(): RuntimeErrorCategory {
    if (this.status === 401 || this.status === 403) return 'permission_denied'
    if (this.status === 409 || this.status === 412) return 'concurrency_conflict'
    if (this.status === 400 || this.status === 422) return 'business_error'
    if (this.status === 404) {
      return this.code.includes('scope') || this.code.includes('hidden')
        ? 'data_scope_hidden'
        : 'not_found'
    }
    return 'transport_error'
  }
}

export function runtimeApiError(error: unknown): RuntimeApiError | undefined {
  return error instanceof RuntimeApiError ? error : undefined
}

export interface RuntimeRequestOptions extends Omit<RequestInit, 'body'> {
  auth?: boolean
  body?: unknown
  surfaceContext?: boolean
  requestId?: string
  token?: string
}

export interface RuntimeClientOptions {
  apiBaseUrl?: string
  workspaceId?: string
  surface: RuntimeProductSurface
  getAccessToken?: () => string | undefined
}

const REQUEST_ID_HEADER = 'X-Request-ID'
const PRODUCT_SURFACE_HEADER = 'X-Domainry-Product-Surface'

export function createRuntimeRequestID() {
  const random = typeof globalThis.crypto?.randomUUID === 'function'
    ? globalThis.crypto.randomUUID()
    : `${Date.now().toString(36)}_${Math.random().toString(36).slice(2)}`
  return `web_${random}`
}

function operationReasonHeaderValue(reason: string) {
  const normalized = reason.trim()
  if (/^[\x20-\x7e]*$/.test(normalized)) return normalized
  return `UTF-8''${encodeURIComponent(normalized)}`
}

async function readRuntimePayload(response: Response): Promise<RuntimeErrorPayload> {
  const contentType = response.headers.get('content-type') ?? ''
  const payload = contentType.includes('application/json')
    ? ((await response.json()) as RuntimeErrorPayload)
    : ({ detail: await response.text() } satisfies RuntimeErrorPayload)
  payload.request_id ||= response.headers.get(REQUEST_ID_HEADER)?.trim() || undefined
  return payload
}

async function consumeNotificationSyncStream(
  response: Response,
  onEvent: (event: string, id: string, data: string) => void | Promise<void>,
  signal: AbortSignal,
) {
  if (!response.body) throw new Error('Notification stream response has no body')
  const reader = response.body.getReader()
  const decoder = new TextDecoder()
  let buffer = ''
  while (!signal.aborted) {
    const { value, done } = await reader.read()
    buffer += decoder.decode(value, { stream: !done }).replace(/\r\n/g, '\n')
    let boundary = buffer.indexOf('\n\n')
    while (boundary >= 0) {
      const block = buffer.slice(0, boundary)
      buffer = buffer.slice(boundary + 2)
      let event = 'message'
      let id = ''
      const data: string[] = []
      for (const line of block.split('\n')) {
        if (line.startsWith('event:')) event = line.slice(6).trim()
        else if (line.startsWith('id:')) id = line.slice(3).trim()
        else if (line.startsWith('data:')) data.push(line.slice(5).trimStart())
      }
      if (data.length) await onEvent(event, id, data.join('\n'))
      boundary = buffer.indexOf('\n\n')
    }
    if (done) return
  }
}

function notificationReconnectDelay(signal: AbortSignal, delayMs: number) {
  return new Promise<void>((resolve) => {
    if (signal.aborted) return resolve()
    const timer = setTimeout(resolve, delayMs)
    signal.addEventListener('abort', () => { clearTimeout(timer); resolve() }, { once: true })
  })
}

export class RuntimeClient {
  readonly apiBaseUrl: string
  readonly workspaceId: string
  readonly surface: RuntimeProductSurface
  private readonly getAccessToken?: () => string | undefined
  private readonly preparedReportExportFiles = new Map<string, RuntimeReportExportFile>()

  constructor({
    apiBaseUrl = '/api',
    workspaceId = 'default',
    surface,
    getAccessToken,
  }: RuntimeClientOptions) {
    this.apiBaseUrl = apiBaseUrl.replace(/\/$/, '')
    this.workspaceId = workspaceId
    this.surface = surface
    this.getAccessToken = getAccessToken
  }

  async request<T>(
    path: string,
    options: RuntimeRequestOptions = {},
  ): Promise<T> {
    return (await this.requestWithResponse<T>(path, options)).data
  }

  async getFileScan(fileID: string): Promise<RuntimeFileScanEvidence> {
    return this.request<RuntimeFileScanEvidence>(`/files/${encodeURIComponent(fileID)}/scan`)
  }

  async uploadFile(
    file: Blob,
    objectKey: string,
    fieldKey: string,
    options: { filename?: string; requestId?: string } = {},
  ): Promise<RuntimeUploadedFile> {
    if (!objectKey.trim() || !fieldKey.trim()) throw new Error('objectKey and fieldKey are required')
    const form = new FormData()
    form.append('file', file, options.filename?.trim() || ('name' in file && typeof file.name === 'string' ? file.name : 'upload.bin'))
    const headers = new Headers()
    headers.set(REQUEST_ID_HEADER, options.requestId?.trim() || createRuntimeRequestID())
    headers.set(PRODUCT_SURFACE_HEADER, this.surface)
    headers.set('X-Workspace-ID', this.workspaceId)
    headers.set('Accept', 'application/json')
    const accessToken = this.getAccessToken?.()
    if (accessToken) headers.set('Authorization', `Bearer ${accessToken}`)
    const query = new URLSearchParams({ object_key: objectKey.trim(), field_key: fieldKey.trim() })
    const response = await fetch(`${this.apiBaseUrl}/files?${query.toString()}`, {
      method: 'POST', cache: 'no-store', headers, body: form,
    })
    const payload = await readRuntimePayload(response)
    if (!response.ok) {
      throw new RuntimeApiError(response.status, payload, payload.message ?? payload.error ?? payload.detail ?? `Runtime upload failed (${response.status})`)
    }
    return payload as unknown as RuntimeUploadedFile
  }

  downloadUpload(filename: string, options: RuntimeFileDownloadOptions) {
    if (!filename.trim() || !options.objectKey.trim() || !options.fieldKey.trim()) {
      throw new Error('filename, objectKey and fieldKey are required')
    }
    const query = new URLSearchParams({ object_key: options.objectKey.trim(), field_key: options.fieldKey.trim() })
    if (options.recordId?.trim()) query.set('record_id', options.recordId.trim())
    return this.file(`/uploads/${encodeURIComponent(filename)}?${query.toString()}`, { requestId: options.requestId })
  }

  async requestWithResponse<T>(
    path: string,
    { auth = true, body, surfaceContext = true, requestId, token, headers, ...init }: RuntimeRequestOptions = {},
  ): Promise<{ data: T; headers: Headers; status: number }> {
    const requestHeaders = new Headers(headers)
    requestHeaders.set(
      REQUEST_ID_HEADER,
      requestId?.trim()
        || requestHeaders.get(REQUEST_ID_HEADER)?.trim()
        || createRuntimeRequestID(),
    )
    if (surfaceContext) requestHeaders.set(PRODUCT_SURFACE_HEADER, this.surface)
    requestHeaders.set('X-Workspace-ID', this.workspaceId)
    requestHeaders.set('Accept', 'application/json')
    if (body !== undefined) requestHeaders.set('Content-Type', 'application/json')
    const accessToken = token ?? this.getAccessToken?.()
    if (auth && accessToken) requestHeaders.set('Authorization', `Bearer ${accessToken}`)

    const response = await fetch(`${this.apiBaseUrl}${path}`, {
      ...init,
      cache: init.cache ?? 'no-store',
      headers: requestHeaders,
      body: body === undefined ? undefined : JSON.stringify(body),
    })
    if (response.status === 204) return { data: undefined as T, headers: response.headers, status: response.status }

    const payload = await readRuntimePayload(response)
    if (!response.ok) {
      throw new RuntimeApiError(
        response.status,
        payload,
        payload.message
          ?? payload.error
          ?? payload.detail
          ?? `Runtime request failed (${response.status})`,
      )
    }
    return { data: payload as T, headers: response.headers, status: response.status }
  }

  async file(
    path: string,
    { auth = true, surfaceContext = true, requestId, token, headers, ...init }: Omit<RuntimeRequestOptions, 'body'> = {},
  ): Promise<{ blob: Blob; filename?: string }> {
    const requestHeaders = new Headers(headers)
    requestHeaders.set(
      REQUEST_ID_HEADER,
      requestId?.trim()
        || requestHeaders.get(REQUEST_ID_HEADER)?.trim()
        || createRuntimeRequestID(),
    )
    if (surfaceContext) requestHeaders.set(PRODUCT_SURFACE_HEADER, this.surface)
    requestHeaders.set('X-Workspace-ID', this.workspaceId)
    const accessToken = token ?? this.getAccessToken?.()
    if (auth && accessToken) requestHeaders.set('Authorization', `Bearer ${accessToken}`)
    const response = await fetch(`${this.apiBaseUrl}${path}`, {
      ...init,
      cache: init.cache ?? 'no-store',
      headers: requestHeaders,
    })
    if (!response.ok) {
      const payload = await readRuntimePayload(response)
      throw new RuntimeApiError(
        response.status,
        payload,
        payload.message
          ?? payload.error
          ?? payload.detail
          ?? `Runtime request failed (${response.status})`,
      )
    }
    const disposition = response.headers.get('content-disposition') ?? ''
    const filename = disposition.match(/filename="?([^";]+)"?/i)?.[1]
    return { blob: await response.blob(), filename }
  }

  async requestFileOrJSON<T>(
    path: string,
    { auth = true, body, surfaceContext = true, requestId, token, headers, ...init }: RuntimeRequestOptions = {},
  ): Promise<T | RuntimeReportExportFile> {
    const requestHeaders = new Headers(headers)
    requestHeaders.set(REQUEST_ID_HEADER, requestId?.trim() || requestHeaders.get(REQUEST_ID_HEADER)?.trim() || createRuntimeRequestID())
    if (surfaceContext) requestHeaders.set(PRODUCT_SURFACE_HEADER, this.surface)
    requestHeaders.set('X-Workspace-ID', this.workspaceId)
    requestHeaders.set('Accept', 'application/json, text/csv')
    if (body !== undefined) requestHeaders.set('Content-Type', 'application/json')
    const accessToken = token ?? this.getAccessToken?.()
    if (auth && accessToken) requestHeaders.set('Authorization', `Bearer ${accessToken}`)
    const response = await fetch(`${this.apiBaseUrl}${path}`, { ...init, cache: init.cache ?? 'no-store', headers: requestHeaders, body: body === undefined ? undefined : JSON.stringify(body) })
    if (!response.ok) {
      const payload = await readRuntimePayload(response)
      throw new RuntimeApiError(response.status, payload, payload.message ?? payload.error ?? payload.detail ?? `Runtime request failed (${response.status})`)
    }
    if ((response.headers.get('content-type') ?? '').includes('application/json')) return (await response.json()) as T
    const disposition = response.headers.get('content-disposition') ?? ''
    return {
      blob: await response.blob(),
      filename: disposition.match(/filename="?([^";]+)"?/i)?.[1],
      artifact_id: response.headers.get('x-report-export-artifact-id') ?? undefined,
      content_sha256: response.headers.get('x-content-sha256') ?? undefined,
      download_token: response.headers.get('x-report-export-download-token') ?? undefined,
      row_count: Number(response.headers.get('x-report-export-row-count') ?? '') || 0,
      expires_at: response.headers.get('x-report-export-expires-at') ?? undefined,
    }
  }

  login(login: string, password: string) {
    return this.request<RuntimeAuthResponse>('/auth/login', {
      method: 'POST',
      auth: false,
      surfaceContext: false,
      body: {
        workspace_id: this.workspaceId,
        login,
        password
      },
    })
  }

  listAuthProviders() {
    return this.request<RuntimeAuthProvider[]>('/auth/providers', { auth: false, surfaceContext: false })
  }

  startOTP(provider: string, phone: string) {
    return this.request<RuntimeAuthProviderStartResponse>(`/auth/providers/${encodeURIComponent(provider)}/start`, {
      method: 'POST',
      auth: false,
      surfaceContext: false,
      body: { workspace_id: this.workspaceId, phone },
    })
  }

  verifyOTP(provider: string, state: string, code: string) {
    return this.request<RuntimeAuthResponse>(`/auth/providers/${encodeURIComponent(provider)}/verify`, {
      method: 'POST',
      auth: false,
      surfaceContext: false,
      body: { workspace_id: this.workspaceId, state, code },
    })
  }

  changePassword(
    currentPassword: string,
    newPassword: string,
    token: string,
    idempotencyKey: string,
  ) {
    if (!idempotencyKey.trim()) throw new Error('Idempotency-Key is required')
    return this.request<RuntimeAuthResponse>('/auth/change-password', {
      method: 'POST',
      token,
      surfaceContext: false,
      headers: { 'Idempotency-Key': idempotencyKey },
      body: {
        current_password: currentPassword,
        new_password: newPassword,
      },
    })
  }

  refresh(refreshToken: string) {
    return this.request<RuntimeAuthResponse>('/auth/refresh', {
      method: 'POST',
      auth: false,
      surfaceContext: false,
      body: {
        workspace_id: this.workspaceId,
        refresh_token: refreshToken
      },
    })
  }

  logout(refreshToken: string) {
    return this.request<{ ok: boolean }>('/auth/logout', {
      method: 'POST',
      auth: false,
      surfaceContext: false,
      body: {
        workspace_id: this.workspaceId,
        refresh_token: refreshToken,
      },
    })
  }

  revokeOtherSessions(idempotencyKey: string, token?: string) {
    if (!idempotencyKey.trim()) throw new Error('Idempotency-Key is required')
    return this.request<RuntimeSessionRevocationResponse>('/auth/sessions/revoke-others', {
      method: 'POST',
      token,
      surfaceContext: false,
      headers: { 'Idempotency-Key': idempotencyKey },
    })
  }

  forceLogoutIdentityUser(userID: string, idempotencyKey: string) {
    if (!userID.trim()) throw new Error('userID is required')
    if (!idempotencyKey.trim()) throw new Error('Idempotency-Key is required')
    return this.request<RuntimeSessionRevocationResponse>(`/identity/users/${encodeURIComponent(userID)}/force-logout`, {
      method: 'POST',
      headers: { 'Idempotency-Key': idempotencyKey },
    })
  }

  me(token?: string) {
    return this.request<RuntimeAuthMeResponse>('/auth/me', { token, surfaceContext: false })
  }

  listWorkforce(query: RuntimeWorkforceQuery = {}) {
    const params = new URLSearchParams({ projection: 'application' })
    if (query.page !== undefined) params.set('page', String(query.page))
    if (query.pageSize !== undefined) params.set('page_size', String(query.pageSize))
    if (query.search?.trim()) params.set('search', query.search.trim())
    if (query.departmentId?.trim()) params.set('department_id', query.departmentId.trim())
    if (query.workStatus) params.set('work_status', query.workStatus)
    return this.request<RuntimeWorkforceApplicationPage>(`/identity/workforce?${params.toString()}`)
  }

  getWorkforce(profileID: string) {
    return this.request<{
      profile: RuntimeWorkforceProfile
      assignments: RuntimeWorkforceAssignment[]
      account: RuntimeIdentityAccount
      business_profiles: Array<Record<string, unknown>>
    }>(`/identity/workforce/${encodeURIComponent(profileID)}/detail`)
  }

  getWorkforceProfile(profileID: string) {
    return this.request<RuntimeWorkforceProfile>(`/identity/workforce/${encodeURIComponent(profileID)}`)
  }

  searchWorkforce(query: RuntimeWorkforceQuery = {}) {
    const params = new URLSearchParams()
    if (query.page !== undefined) params.set('page', String(query.page))
    if (query.pageSize !== undefined) params.set('page_size', String(query.pageSize))
    if (query.search?.trim()) params.set('search', query.search.trim())
    if (query.departmentId?.trim()) params.set('department_id', query.departmentId.trim())
    if (query.workStatus) params.set('work_status', query.workStatus)
    return this.request<RuntimeWorkforceApplicationPage>(`/identity/workforce/search?${params.toString()}`)
  }

  listDepartments() {
    return this.request<RuntimeDepartment[]>('/identity/departments')
  }

  getDepartment(departmentID: string) {
    return this.request<RuntimeDepartment>(`/identity/departments/${encodeURIComponent(departmentID)}`)
  }

  createDepartment(department: RuntimeDepartment, idempotencyKey: string) {
    if (!idempotencyKey.trim()) throw new Error('Idempotency-Key is required')
    return this.request<RuntimeDepartment | RuntimeAuthoringResult<RuntimeDepartment>>('/identity/departments', {
      method: 'POST', headers: {
        'Builder-Task-ID': `runtime-client.identity-department.${idempotencyKey}`,
        'Idempotency-Key': idempotencyKey,
        'Expected-Schema-Hash': 'empty',
      }, body: department,
    }).then(runtimeAuthoringResource)
  }

  async updateDepartment(departmentID: string, department: RuntimeDepartment) {
    const path = `/identity/departments/${encodeURIComponent(departmentID)}`
    const current = await this.requestWithResponse<RuntimeDepartment>(path)
    const expected = current.headers.get('X-Resource-Hash')?.trim()
    if (!expected) throw new Error('Runtime did not publish the department resource hash')
    const idempotencyKey = createRuntimeRequestID()
    const result = await this.request<RuntimeDepartment | RuntimeAuthoringResult<RuntimeDepartment>>(path, {
      method: 'PATCH', headers: {
        'Builder-Task-ID': `runtime-client.identity-department.${idempotencyKey}`,
        'Idempotency-Key': idempotencyKey,
        'Expected-Schema-Hash': expected,
      }, body: department,
    })
    return runtimeAuthoringResource(result)
  }

  validateDepartment(departmentID: string, department: RuntimeDepartment) {
    return this.request<{ valid: boolean }>(`/identity/departments/${encodeURIComponent(departmentID)}/validate`, {
      method: 'POST', body: department,
    })
  }

  createWorkforceProfile(profile: RuntimeWorkforceProfile, idempotencyKey: string) {
    if (!idempotencyKey.trim()) throw new Error('Idempotency-Key is required')
    return this.request<RuntimeWorkforceProfile | RuntimeAuthoringResult<RuntimeWorkforceProfile>>('/identity/workforce', {
      method: 'POST', headers: {
        'Builder-Task-ID': `runtime-client.identity-workforce-profile.${idempotencyKey}`,
        'Idempotency-Key': idempotencyKey,
        'Expected-Schema-Hash': 'empty',
      }, body: profile,
    }).then(runtimeAuthoringResource)
  }

  async updateWorkforceProfile(profileID: string, profile: RuntimeWorkforceProfile) {
    const path = `/identity/workforce/${encodeURIComponent(profileID)}`
    const current = await this.requestWithResponse<RuntimeWorkforceProfile>(path)
    const expected = current.headers.get('X-Resource-Hash')?.trim()
    if (!expected) throw new Error('Runtime did not publish the Workforce profile resource hash')
    const idempotencyKey = createRuntimeRequestID()
    const result = await this.request<RuntimeWorkforceProfile | RuntimeAuthoringResult<RuntimeWorkforceProfile>>(path, {
      method: 'PATCH', headers: {
        'Builder-Task-ID': `runtime-client.identity-workforce-profile.${idempotencyKey}`,
        'Idempotency-Key': idempotencyKey,
        'Expected-Schema-Hash': expected,
      }, body: profile,
    })
    return runtimeAuthoringResource(result)
  }

  validateWorkforceProfile(profileID: string, profile: RuntimeWorkforceProfile) {
    return this.request<{ valid: boolean }>(`/identity/workforce/${encodeURIComponent(profileID)}/validate`, {
      method: 'POST', body: profile,
    })
  }

  onboardWorkforce(request: RuntimeWorkforceOnboardingRequest, idempotencyKey: string) {
    if (!idempotencyKey.trim()) throw new Error('Idempotency-Key is required')
    return this.request<RuntimeWorkforceOnboardingResult>('/identity/workforce/onboard', {
      method: 'POST', headers: { 'Idempotency-Key': idempotencyKey }, body: request,
    })
  }

  applyWorkforceLifecycle(profileID: string, request: RuntimeWorkforceLifecycleRequest, idempotencyKey: string) {
    if (!idempotencyKey.trim()) throw new Error('Idempotency-Key is required')
    return this.request<RuntimeWorkforceLifecycleResult>(`/identity/workforce/${encodeURIComponent(profileID)}/lifecycle`, {
      method: 'POST', headers: { 'Idempotency-Key': idempotencyKey }, body: request,
    })
  }

  transferWorkforce(items: RuntimeWorkforceTransferItem[], idempotencyKey: string) {
    if (!idempotencyKey.trim()) throw new Error('Idempotency-Key is required')
    return this.request<RuntimeWorkforceTransferReceipt>('/identity/workforce/transfers/batch', {
      method: 'POST', headers: { 'Idempotency-Key': idempotencyKey }, body: { items },
    })
  }

  terminateWorkforce(
    profileID: string,
    request: RuntimeWorkforceTerminationRequest,
    options: { idempotencyKey: string; requestId?: string },
  ) {
    if (!options.idempotencyKey.trim()) throw new Error('Idempotency-Key is required')
    return this.request<RuntimeWorkforceProfile>(`/identity/workforce/${encodeURIComponent(profileID)}/terminate`, {
      method: 'POST', requestId: options.requestId,
      headers: { 'Idempotency-Key': options.idempotencyKey }, body: request,
    })
  }

  rehireWorkforce(
    profileID: string,
    request: RuntimeWorkforceRehireRequest,
    options: { idempotencyKey: string; requestId?: string },
  ) {
    if (!options.idempotencyKey.trim()) throw new Error('Idempotency-Key is required')
    return this.request<RuntimeWorkforceLifecycleResult>(`/identity/workforce/${encodeURIComponent(profileID)}/rehire`, {
      method: 'POST', requestId: options.requestId,
      headers: { 'Idempotency-Key': options.idempotencyKey }, body: request,
    })
  }

  listAssignableWorkforceRoles(profileID: string) {
    return this.request<Array<Record<string, unknown>>>(`/identity/workforce/${encodeURIComponent(profileID)}/assignable-roles`)
  }

  listWorkforceAssignments(profileID: string) {
    return this.request<{ items: RuntimeWorkforceAssignment[]; total: number }>(`/identity/workforce/${encodeURIComponent(profileID)}/assignments`)
  }

  async upsertWorkforceAssignment(profileID: string, assignment: RuntimeWorkforceAssignment, idempotencyKey: string) {
    if (!idempotencyKey.trim()) throw new Error('Idempotency-Key is required')
    const path = `/identity/workforce/${encodeURIComponent(profileID)}/assignments`
    const current = await this.requestWithResponse<{ items: RuntimeWorkforceAssignment[]; total: number }>(path)
    const expected = current.headers.get('X-Resource-Hash')?.trim()
    if (!expected) throw new Error('Runtime did not publish the Workforce assignment resource hash')
    const result = await this.request<RuntimeWorkforceAssignment | RuntimeAuthoringResult<RuntimeWorkforceAssignment>>(path, {
      method: 'POST', headers: {
        'Builder-Task-ID': `runtime-client.identity-workforce-assignment.${idempotencyKey}`,
        'Idempotency-Key': idempotencyKey,
        'Expected-Schema-Hash': expected,
      }, body: assignment,
    })
    return runtimeAuthoringResource(result)
  }

  validateWorkforceAssignment(profileID: string, assignment: RuntimeWorkforceAssignment) {
    return this.request<{ valid: boolean }>(`/identity/workforce/${encodeURIComponent(profileID)}/assignments/validate`, {
      method: 'POST', body: assignment,
    })
  }

  listDepartmentVersions(departmentID: string) {
    return this.request<Array<Record<string, unknown>>>(`/identity/departments/${encodeURIComponent(departmentID)}/versions`)
  }

  listJobs() {
    return this.request<{ items: RuntimeJobCatalogItem[]; total: number }>('/foundation/jobs')
  }

  getJob(jobID: string) {
    return this.request<RuntimeJobCatalogItem>(`/foundation/jobs/${encodeURIComponent(jobID)}`)
  }

  upsertJob(jobID: string, job: RuntimeJobCatalogItem) {
    return this.request<RuntimeJobCatalogItem>(`/foundation/jobs/${encodeURIComponent(jobID)}`, { method: 'PUT', body: job })
  }

  listPositions() {
    return this.request<{ items: RuntimePosition[]; total: number }>('/foundation/positions')
  }

  getPosition(positionID: string) {
    return this.request<RuntimePosition>(`/foundation/positions/${encodeURIComponent(positionID)}`)
  }

  upsertPosition(positionID: string, position: RuntimePosition) {
    return this.request<RuntimePosition>(`/foundation/positions/${encodeURIComponent(positionID)}`, { method: 'PUT', body: position })
  }

  listEffectiveMenus(surface: RuntimeProductSurface = this.surface) {
    return this.request<RuntimeEffectiveMenu[]>(`/identity/effective-menus?surface=${encodeURIComponent(surface)}`)
  }

  queryRecords<TData extends Record<string, unknown> = Record<string, unknown>>(
    objectKey: string,
    query: RuntimeRecordQuery = {},
  ) {
    const params = new URLSearchParams()
    if (query.page !== undefined) params.set('page', String(query.page))
    if (query.pageSize !== undefined) params.set('page_size', String(query.pageSize))
    if (query.search?.trim()) params.set('search', query.search.trim())
    if (query.view?.trim()) params.set('view', query.view.trim())
    if (query.filters) params.set('filters', JSON.stringify(query.filters))
    if (query.sort?.length) {
      params.set(
        'sort',
        query.sort
          .map(({ field, direction = 'asc' }) => `${field.trim()}:${direction}`)
          .join(','),
      )
    }
    const suffix = params.size ? `?${params.toString()}` : ''
    return this.request<RuntimeRecordPage<TData>>(
      `/objects/${encodeURIComponent(objectKey)}/records${suffix}`,
    )
  }

  getRecord<TData extends Record<string, unknown> = Record<string, unknown>>(
    objectKey: string,
    recordID: string,
  ) {
    return this.request<RuntimeRecord<TData>>(
      `/objects/${encodeURIComponent(objectKey)}/records/${encodeURIComponent(recordID)}`,
    )
  }

  listActions(objectKey: string) {
    return this.request<RuntimeActionDefinition[]>(
      `/objects/${encodeURIComponent(objectKey)}/actions`,
    )
  }

  createRecord<TData extends Record<string, unknown> = Record<string, unknown>>(
    objectKey: string,
    data: TData,
    options: RuntimeMutationOptions & { idempotencyKey: string },
  ) {
    return this.request<RuntimeRecord<TData>>(
      `/objects/${encodeURIComponent(objectKey)}/records`,
      {
        method: 'POST',
        requestId: options.requestId,
        headers: { 'Idempotency-Key': options.idempotencyKey },
        body: { data },
      },
    )
  }

  claimIdentityProfile(
    objectKey: string,
    profileID: string,
    bindingKey: string,
    proofType: string,
    proofValue: string,
    idempotencyKey: string,
  ) {
    return this.request<unknown>(
      `/identity/profile-bindings/${encodeURIComponent(objectKey)}/${encodeURIComponent(profileID)}/commands`,
      {
        method: 'POST',
        headers: { 'Idempotency-Key': idempotencyKey },
        body: {
          binding_key: bindingKey,
          operation: 'claim',
          claim_proof_type: proofType,
          claim_proof_value: proofValue,
          expected_version: 0,
          idempotency_key: idempotencyKey,
        },
      },
    )
  }

  updateRecord<TData extends Record<string, unknown> = Record<string, unknown>>(
    objectKey: string,
    recordID: string,
    data: Partial<TData>,
    options: RuntimeMutationOptions = {},
  ) {
    const headers = new Headers()
    if (options.idempotencyKey) headers.set('Idempotency-Key', options.idempotencyKey)
    if (options.expectedUpdatedAt) headers.set('If-Match', options.expectedUpdatedAt)
    return this.request<RuntimeRecord<TData>>(
      `/objects/${encodeURIComponent(objectKey)}/records/${encodeURIComponent(recordID)}`,
      { method: 'PATCH', requestId: options.requestId, headers, body: { data } },
    )
  }

  deleteRecord(
    objectKey: string,
    recordID: string,
    options: Pick<RuntimeMutationOptions, 'expectedUpdatedAt' | 'requestId'> = {},
  ) {
    const headers = new Headers()
    if (options.expectedUpdatedAt) headers.set('If-Match', options.expectedUpdatedAt)
    return this.request<void>(
      `/objects/${encodeURIComponent(objectKey)}/records/${encodeURIComponent(recordID)}`,
      { method: 'DELETE', requestId: options.requestId, headers },
    )
  }

  runObjectAction<TInput extends Record<string, unknown>, TResult = unknown>(
    objectKey: string,
    actionKey: string,
    data: TInput,
    options: RuntimeActionOptions & { idempotencyKey: string },
  ) {
    return this.request<RuntimeObjectActionResult<TResult>>(
      `/objects/${encodeURIComponent(objectKey)}/actions/${encodeURIComponent(actionKey)}/run`,
      {
        method: 'POST',
        requestId: options.requestId,
        headers: { 'Idempotency-Key': options.idempotencyKey },
        body: {
          data,
          idempotency_key: options.idempotencyKey,
          assurance_token: options.assuranceToken,
        },
      },
    )
  }

  runRecordAction<
    TInput extends Record<string, unknown>,
    TRecordData extends Record<string, unknown> = Record<string, unknown>,
    TResult = unknown,
  >(
    objectKey: string,
    recordID: string,
    actionKey: string,
    data: TInput,
    options: RuntimeActionOptions & { idempotencyKey: string },
  ) {
    return this.request<RuntimeRecordActionResult<TRecordData, TResult>>(
      `/objects/${encodeURIComponent(objectKey)}/records/${encodeURIComponent(recordID)}/actions/${encodeURIComponent(actionKey)}`,
      {
        method: 'POST',
        requestId: options.requestId,
        headers: { 'Idempotency-Key': options.idempotencyKey },
        body: {
          data,
          assurance_token: options.assuranceToken,
        },
      },
    )
  }

  runBulkAction(
    objectKey: string,
    actionKey: string,
    request: RuntimeBulkActionRequest,
    options: { idempotencyKey: string; requestId?: string },
  ) {
    if (!options.idempotencyKey.trim()) throw new Error('Idempotency-Key is required')
    return this.request<RuntimeBulkActionResult>(
      `/objects/${encodeURIComponent(objectKey)}/actions/${encodeURIComponent(actionKey)}/bulk`,
      {
        method: 'POST', requestId: options.requestId,
        headers: { 'Idempotency-Key': options.idempotencyKey }, body: request,
      },
    )
  }

  previewRecordImport(objectKey: string, csv: string, options: { requestId?: string } = {}) {
    return this.request<RuntimeRecordImportPreview>(
      `/objects/${encodeURIComponent(objectKey)}/records/import/preview`,
      { method: 'POST', requestId: options.requestId, body: { csv } },
    )
  }

  applyRecordImport(
    objectKey: string,
    csv: string,
    options: { idempotencyKey: string; requestId?: string },
  ) {
    if (!options.idempotencyKey.trim()) throw new Error('Idempotency-Key is required')
    return this.request<RuntimeRecordImportApplyResult>(
      `/objects/${encodeURIComponent(objectKey)}/records/import/apply`,
      {
        method: 'POST', requestId: options.requestId,
        headers: { 'Idempotency-Key': options.idempotencyKey }, body: { csv },
      },
    )
  }

  enqueueRecordImport(
    objectKey: string,
    csv: string,
    options: { idempotencyKey: string; requestId?: string },
  ) {
    if (!options.idempotencyKey.trim()) throw new Error('Idempotency-Key is required')
    return this.request<RuntimeRecordBatchJob>(
      `/objects/${encodeURIComponent(objectKey)}/records/import/jobs`,
      {
        method: 'POST', requestId: options.requestId,
        headers: { 'Idempotency-Key': options.idempotencyKey }, body: { csv },
      },
    )
  }

  exportRecords(
    objectKey: string,
    options: { fields?: readonly string[]; reason?: string; maskingPolicy?: string; filterSummary?: string; requestId?: string } = {},
  ) {
    const params = new URLSearchParams()
    if (options.fields?.length) params.set('fields', options.fields.join(','))
    if (options.reason?.trim()) params.set('reason', options.reason.trim())
    if (options.maskingPolicy?.trim()) params.set('masking_policy', options.maskingPolicy.trim())
    if (options.filterSummary?.trim()) params.set('filter_summary', options.filterSummary.trim())
    const suffix = params.size ? `?${params.toString()}` : ''
    return this.file(`/objects/${encodeURIComponent(objectKey)}/records/export${suffix}`, { requestId: options.requestId })
  }

  enqueueRecordExport(
    objectKey: string,
    options: { idempotencyKey: string; fields?: readonly string[]; reason?: string; maskingPolicy?: string; filterSummary?: string; requestId?: string },
  ) {
    if (!options.idempotencyKey.trim()) throw new Error('Idempotency-Key is required')
    const params = new URLSearchParams()
    if (options.fields?.length) params.set('fields', options.fields.join(','))
    if (options.reason?.trim()) params.set('reason', options.reason.trim())
    if (options.maskingPolicy?.trim()) params.set('masking_policy', options.maskingPolicy.trim())
    if (options.filterSummary?.trim()) params.set('filter_summary', options.filterSummary.trim())
    const suffix = params.size ? `?${params.toString()}` : ''
    return this.request<RuntimeRecordBatchJob>(
      `/objects/${encodeURIComponent(objectKey)}/records/export/jobs${suffix}`,
      { method: 'POST', requestId: options.requestId, headers: { 'Idempotency-Key': options.idempotencyKey } },
    )
  }

  getRecordBatchJob(jobID: string, options: { requestId?: string } = {}) {
    return this.request<RuntimeRecordBatchJob>(`/record-batch-jobs/${encodeURIComponent(jobID)}`, { requestId: options.requestId })
  }

  cancelRecordBatchJob(jobID: string, options: { idempotencyKey: string; requestId?: string }) {
    if (!options.idempotencyKey.trim()) throw new Error('Idempotency-Key is required')
    return this.request<RuntimeRecordBatchJob>(`/record-batch-jobs/${encodeURIComponent(jobID)}/cancel`, {
      method: 'POST', requestId: options.requestId, headers: { 'Idempotency-Key': options.idempotencyKey },
    })
  }

  downloadRecordBatchJob(jobID: string, options: { requestId?: string } = {}) {
    return this.file(`/record-batch-jobs/${encodeURIComponent(jobID)}/download`, { requestId: options.requestId })
  }

  listWorkflowProcesses(query: RuntimeWorkflowProcessQuery = {}) {
    const params = new URLSearchParams()
    if (query.resourceId?.trim()) params.set('resource_id', query.resourceId.trim())
    if (query.workflowKey?.trim()) params.set('workflow_key', query.workflowKey.trim())
    if (query.definitionVersion !== undefined) params.set('definition_version', String(query.definitionVersion))
    if (query.objectKey?.trim()) params.set('object_key', query.objectKey.trim())
    if (query.recordId?.trim()) params.set('record_id', query.recordId.trim())
    query.statuses?.forEach((status) => {
      if (status.trim()) params.append('status', status.trim())
    })
    if (query.initiatorId?.trim()) params.set('initiator_id', query.initiatorId.trim())
    if (query.approverId?.trim()) params.set('approver_id', query.approverId.trim())
    if (query.updatedFrom?.trim()) params.set('updated_from', query.updatedFrom.trim())
    if (query.updatedTo?.trim()) params.set('updated_to', query.updatedTo.trim())
    if (query.limit !== undefined) params.set('limit', String(query.limit))
    const suffix = params.size ? `?${params.toString()}` : ''
    return this.request<RuntimeWorkflowProcess[]>(`/business/workflow/processes${suffix}`)
  }

  listBusinessAuditEvents(query: RuntimeBusinessAuditQuery = {}) {
    if (this.surface !== 'business_workspace') {
      throw new Error('Business audit events require the business_workspace Surface')
    }
    const params = new URLSearchParams()
    if (query.objectKey?.trim()) params.set('object_key', query.objectKey.trim())
    if (query.recordId?.trim()) params.set('record_id', query.recordId.trim())
    if (query.event?.trim()) params.set('event', query.event.trim())
    if (query.actorId?.trim()) params.set('actor_id', query.actorId.trim())
    if (query.roleKey?.trim()) params.set('role_key', query.roleKey.trim())
    if (query.requestId?.trim()) params.set('request_id', query.requestId.trim())
    if (query.createdFrom?.trim()) params.set('created_from', query.createdFrom.trim())
    if (query.createdTo?.trim()) params.set('created_to', query.createdTo.trim())
    if (query.limit !== undefined) params.set('limit', String(query.limit))
    const suffix = params.size ? `?${params.toString()}` : ''
    return this.request<RuntimeBusinessAuditPage>(`/business/audit-events${suffix}`)
      .then(({ items }) => items)
  }

  prepareBusinessAuditEventExport(
    request: RuntimeBusinessAuditExportRequest,
    options: { idempotencyKey: string; requestId?: string },
  ) {
    if (this.surface !== 'business_workspace') {
      throw new Error('Business audit-event exports require the business_workspace Surface')
    }
    return this.request<RuntimeBusinessAuditExportPrepared>('/business/audit-event-exports', {
      method: 'POST',
      requestId: options.requestId,
      headers: { 'Idempotency-Key': options.idempotencyKey },
      body: request,
    })
  }

  downloadBusinessAuditEventExport(token: string, options: { requestId?: string } = {}) {
    if (this.surface !== 'business_workspace') {
      throw new Error('Business audit-event exports require the business_workspace Surface')
    }
    return this.file(`/business/audit-event-exports/downloads/${encodeURIComponent(token)}`, {
      requestId: options.requestId,
    })
  }

  getWorkflowProcess(processID: string) {
    return this.request<RuntimeWorkflowProcessDetail>(
      `/business/workflow/processes/${encodeURIComponent(processID)}`,
    )
  }

  listWorkflowTasks(query: RuntimeWorkflowTaskQuery = {}) {
    const params = new URLSearchParams()
    if (query.status?.trim()) params.set('status', query.status.trim())
    if (query.limit !== undefined) params.set('limit', String(query.limit))
    const suffix = params.size ? `?${params.toString()}` : ''
    return this.request<RuntimeWorkflowTask[]>(`/business/workflow/tasks${suffix}`)
  }

  listTeamWorkflowTasks(query: RuntimeWorkflowTaskQuery = {}) {
    const params = new URLSearchParams()
    if (query.status?.trim()) params.set('status', query.status.trim())
    if (query.limit !== undefined) params.set('limit', String(query.limit))
    const suffix = params.size ? `?${params.toString()}` : ''
    return this.request<RuntimeWorkflowTask[]>(`/business/workflow/team-tasks${suffix}`)
  }

  runWorkflow(
    workflowKey: string,
    payload: Record<string, unknown>,
    options: { idempotencyKey: string; requestId?: string },
  ) {
    const prefix = this.surface === 'consumer_portal' ? '/portal' : '/business'
    return this.request<RuntimeWorkflowRunResult>(
      `${prefix}/workflows/${encodeURIComponent(workflowKey)}/run`,
      {
        method: 'POST',
        requestId: options.requestId,
        headers: { 'Idempotency-Key': options.idempotencyKey },
        body: { payload },
      },
    )
  }

  decideWorkflowTask(
    taskID: string,
    decision: RuntimeWorkflowTaskDecision,
    options: { idempotencyKey: string; comment?: string; requestId?: string },
  ) {
    const action = decision === 'approved' ? 'approve' : decision === 'rejected' ? 'reject' : 'return'
    return this.request<RuntimeWorkflowProcess>(
      `/business/workflow/tasks/${encodeURIComponent(taskID)}/${action}`,
      {
        method: 'POST',
        requestId: options.requestId,
        headers: { 'Idempotency-Key': options.idempotencyKey },
        body: { comment: options.comment },
      },
    )
  }

  withdrawWorkflowProcess(
    processID: string,
    options: { idempotencyKey: string; requestId?: string },
  ) {
    return this.request<RuntimeWorkflowProcess>(
      `/business/workflow/processes/${encodeURIComponent(processID)}/withdraw`,
      {
        method: 'POST',
        requestId: options.requestId,
        headers: { 'Idempotency-Key': options.idempotencyKey },
      },
    )
  }

  retryWorkflowProcess(
    processID: string,
    options: { idempotencyKey: string; requestId?: string },
  ) {
    return this.request<RuntimeWorkflowProcess>(
      `/business/workflow/processes/${encodeURIComponent(processID)}/retry`,
      {
        method: 'POST',
        requestId: options.requestId,
        headers: { 'Idempotency-Key': options.idempotencyKey },
      },
    )
  }

  runAgent(
    request: RuntimeAgentInteractiveRunRequest,
    options: { idempotencyKey: string; requestId?: string },
  ) {
    return this.request<RuntimeAgentInteractiveExecutionResult>('/agent-dialog/runs', {
      method: 'POST',
      requestId: options.requestId,
      headers: { 'Idempotency-Key': options.idempotencyKey },
      body: request,
    })
  }

  async runAgentStream(
    request: RuntimeAgentInteractiveRunRequest,
    options: RuntimeAgentStreamOptions,
  ): Promise<RuntimeAgentInteractiveExecutionResult> {
    if (!options.idempotencyKey.trim()) throw new Error('Idempotency-Key is required')
    const controller = new AbortController()
    const abort = () => controller.abort(options.signal?.reason)
    options.signal?.addEventListener('abort', abort, { once: true })
    if (options.signal?.aborted) controller.abort(options.signal.reason)
    const headers = new Headers({
      [REQUEST_ID_HEADER]: options.requestId?.trim() || createRuntimeRequestID(),
      [PRODUCT_SURFACE_HEADER]: this.surface,
      'X-Workspace-ID': this.workspaceId,
      'Idempotency-Key': options.idempotencyKey.trim(),
      Accept: 'text/event-stream',
      'Content-Type': 'application/json',
    })
    const accessToken = this.getAccessToken?.()
    if (accessToken) headers.set('Authorization', `Bearer ${accessToken}`)
    try {
      const maxReconnectAttempts = Math.min(10, Math.max(0, options.maxReconnectAttempts ?? 3))
      const reconnectDelayMs = Math.min(30_000, Math.max(0, options.reconnectDelayMs ?? 100))
      let lastEventID = ''
      let result: RuntimeAgentInteractiveExecutionResult | undefined
      const deliveredEventIDs = new Set<string>()
      for (let attempt = 0; attempt <= maxReconnectAttempts; attempt += 1) {
        if (lastEventID) headers.set('Last-Event-ID', lastEventID)
        else headers.delete('Last-Event-ID')
        try {
          const response = await fetch(`${this.apiBaseUrl}/agent-dialog/runs/stream`, {
            method: 'POST', cache: 'no-store', headers, body: JSON.stringify(request), signal: controller.signal,
          })
          if (!response.ok) {
            const payload = await readRuntimePayload(response)
            throw new RuntimeApiError(response.status, payload, payload.message ?? payload.error ?? payload.detail ?? `Agent stream failed (${response.status})`)
          }
          if (!(response.headers.get('content-type') ?? '').includes('text/event-stream')) {
            throw new Error('Agent stream returned an invalid content type')
          }
          await consumeNotificationSyncStream(response, (event, id, data) => {
            if (!id) throw new Error('Agent stream event is missing an id')
            lastEventID = id
            if (deliveredEventIDs.has(id)) return
            deliveredEventIDs.add(id)
            const payload = JSON.parse(data) as Record<string, unknown>
            if (event === 'accepted') options.onAccepted?.(payload)
            else if (event === 'result') result = payload as unknown as RuntimeAgentInteractiveExecutionResult
            else if (event === 'error') {
              const errorPayload = payload as RuntimeErrorPayload
              throw new RuntimeApiError(422, errorPayload, errorPayload.message ?? errorPayload.error ?? errorPayload.detail ?? 'Agent stream failed')
            }
          }, controller.signal)
          if (result) return result
        } catch (error) {
          if (controller.signal.aborted || error instanceof RuntimeApiError || (error instanceof Error && (error.message.includes('invalid content type') || error.message.includes('missing an id')))) throw error
          if (attempt >= maxReconnectAttempts) throw error
        }
        if (attempt >= maxReconnectAttempts) break
        await notificationReconnectDelay(controller.signal, reconnectDelayMs * (attempt + 1))
      }
      throw new Error('Agent stream ended without a terminal result after reconnects')
    } finally {
      options.signal?.removeEventListener('abort', abort)
    }
  }

  queryAgentAnalysis(request: RuntimeAgentAnalysisRequest, options: { requestId?: string } = {}) {
    return this.request<RuntimeAgentAnalysisResult>('/agent-dialog/analysis/query', {
      method: 'POST', requestId: options.requestId, body: request,
    })
  }

  getAgentReportQueryRun(queryRef: string, options: { requestId?: string } = {}) {
    return this.request<RuntimeAgentReportState>(`/agent-dialog/report-query-runs/${encodeURIComponent(queryRef)}`, { requestId: options.requestId })
  }

  getAgentReportExportAudit(queryRef: string, options: { requestId?: string } = {}) {
    return this.request<RuntimeAgentReportState>(`/agent-dialog/report-export-audits/${encodeURIComponent(queryRef)}`, { requestId: options.requestId })
  }

  getAgentReportDownloadTask(queryRef: string, options: { requestId?: string } = {}) {
    return this.request<RuntimeAgentReportState>(`/agent-dialog/download-tasks/${encodeURIComponent(queryRef)}`, { requestId: options.requestId })
  }

  prepareAgentReportHandoff(queryRef: string, options: { requestId?: string } = {}) {
    return this.request<RuntimeAgentReportHandoff>(`/agent-dialog/download-tasks/${encodeURIComponent(queryRef)}/prepare`, {
      method: 'POST', requestId: options.requestId,
    })
  }

  getAgentRun(runID: string, options: { requestId?: string } = {}) {
    return this.request<RuntimeAgentInteractiveRun>(
      `/agent-dialog/runs/${encodeURIComponent(runID)}`,
      { requestId: options.requestId },
    )
  }

  getAgentTaskRun(taskRunID: string, options: { requestId?: string } = {}) {
    return this.request<RuntimeAgentTaskRun>(
      `/agent-dialog/task-runs/${encodeURIComponent(taskRunID)}`,
      { requestId: options.requestId },
    )
  }

  listAgentSessions(query: RuntimeAgentSessionQuery = {}, options: { requestId?: string } = {}) {
    const params = new URLSearchParams()
    if (query.search?.trim()) params.set('q', query.search.trim())
    if (query.surface?.trim()) params.set('surface', query.surface.trim())
    if (query.objectKey?.trim()) params.set('object_key', query.objectKey.trim())
    if (query.recordId?.trim()) params.set('record_id', query.recordId.trim())
    if (query.includeArchived) params.set('archived', 'true')
    if (query.limit !== undefined) params.set('limit', String(query.limit))
    const suffix = params.size ? `?${params.toString()}` : ''
    return this.request<{ sessions: RuntimeAgentSession[] }>(`/agent-dialog/sessions${suffix}`, { requestId: options.requestId })
      .then(({ sessions }) => sessions)
  }

  upsertAgentSession(request: RuntimeAgentSessionUpsertRequest, options: { requestId?: string } = {}) {
    return this.request<RuntimeAgentSession>('/agent-dialog/sessions', {
      method: 'POST', requestId: options.requestId, body: request,
    })
  }

  setAgentSessionArchived(externalSessionID: string, archived: boolean, options: { requestId?: string } = {}) {
    return this.request<RuntimeAgentSession>(
      `/agent-dialog/sessions/${encodeURIComponent(externalSessionID)}/${archived ? 'archive' : 'restore'}`,
      { method: 'POST', requestId: options.requestId },
    )
  }

  listAgentProposals(status?: string, options: { requestId?: string } = {}) {
    const suffix = status?.trim() ? `?status=${encodeURIComponent(status.trim())}` : ''
    return this.request<{ proposals: RuntimeAgentProposal[] }>(`/agent-dialog/proposals${suffix}`, { requestId: options.requestId })
      .then(({ proposals }) => proposals)
  }

  getAgentProposal(proposalID: string, options: { requestId?: string } = {}) {
    return this.request<RuntimeAgentProposal>(
      `/agent-dialog/proposals/${encodeURIComponent(proposalID)}`,
      { requestId: options.requestId },
    )
  }

  createAgentProposal(
    proposed: Record<string, unknown>,
    options: { title?: string; summary?: string; source?: string; reference?: string; metadata?: Record<string, unknown>; requestId?: string } = {},
  ) {
    return this.request<RuntimeAgentProposal>('/agent-dialog/proposals', {
      method: 'POST', requestId: options.requestId, body: {
        proposed, title: options.title, summary: options.summary, source: options.source,
        reference: options.reference, metadata: options.metadata,
      },
    })
  }

  decideAgentProposal(
    proposalID: string,
    decision: 'approve' | 'reject',
    options: { reason?: string; metadata?: Record<string, unknown>; requestId?: string } = {},
  ) {
    return this.request<RuntimeAgentProposal>(
      `/agent-dialog/proposals/${encodeURIComponent(proposalID)}/${decision}`,
      { method: 'POST', requestId: options.requestId, body: { reason: options.reason, metadata: options.metadata } },
    )
  }

  getIntegrationIntent(messageID: string) {
    return this.request<RuntimeIntegrationIntentResult>(
      `/business/integration-intents/${encodeURIComponent(messageID)}`,
    )
  }

  getReportSummary(
    reportKey: string,
    options: RuntimeReportPageOptions & { mode?: 'realtime' | 'snapshot'; queryKey?: string; tags?: readonly string[]; requestId?: string } = {},
  ) {
    const params = new URLSearchParams()
    if (options.mode) params.set('mode', options.mode)
    if (options.queryKey?.trim()) params.set('query_key', options.queryKey.trim())
    for (const tag of options.tags ?? []) {
      if (tag.trim()) params.append('tags', tag.trim())
    }
    if (options.pageSize !== undefined) params.set('page_size', String(options.pageSize))
    if (options.cursor?.trim()) params.set('cursor', options.cursor.trim())
    const suffix = params.size ? `?${params.toString()}` : ''
    return this.request<RuntimeReportSummary>(
      `/reports/${encodeURIComponent(reportKey)}/summary${suffix}`,
      { requestId: options.requestId },
    )
  }

  queryReportObjectSQL(
    reportKey: string,
    parameters: Readonly<Record<string, RuntimeReportObjectSQLParameterValue>>,
    options: RuntimeReportPageOptions & { requestId?: string } = {},
  ) {
    return this.request<RuntimeReportSummary>(
      `/reports/${encodeURIComponent(reportKey)}/query`,
      {
        method: 'POST',
        requestId: options.requestId,
        body: { parameters, page_size: options.pageSize, cursor: options.cursor },
      },
    )
  }

  refreshReportSnapshot(
    reportKey: string,
    options: { idempotencyKey: string; requestId?: string },
  ) {
    return this.request<RuntimeReportSnapshot>(
      `/reports/${encodeURIComponent(reportKey)}/snapshots/refresh`,
      {
        method: 'POST',
        requestId: options.requestId,
        headers: { 'Idempotency-Key': options.idempotencyKey },
      },
    )
  }

  prepareReportExportRouted(
    reportKey: string,
    objectKey: string,
    auditId: string,
    options: { idempotencyKey: string; reason: string; scope?: RuntimeReportExportScope; requestId?: string },
  ) {
    return this.requestFileOrJSON<RuntimeReportExportJob>(
      `/reports/${encodeURIComponent(reportKey)}/exports/${encodeURIComponent(objectKey)}/prepare`,
      {
        method: 'POST',
        requestId: options.requestId,
        headers: {
          'Idempotency-Key': options.idempotencyKey,
          'X-Operation-Reason': operationReasonHeaderValue(options.reason),
          'X-Operation-Confirmation': 'confirmed',
        },
        body: {
          audit_id: auditId,
          scope: options.scope ?? { purpose: options.reason.trim(), freshness: { mode: 'realtime' } },
        },
      },
    )
  }

  /**
   * @deprecated Source-compatible bridge for adapters written before routed
   * 200-file/202-job exports. New code must use prepareReportExportRouted.
   */
  async prepareReportExport(
    reportKey: string,
    objectKey: string,
    auditId: string,
    options: { idempotencyKey: string; reason: string; scope?: RuntimeReportExportScope; requestId?: string },
  ): Promise<RuntimeReportExportDownload> {
    const scope = options.scope ?? { purpose: options.reason.trim(), freshness: { mode: 'realtime' as const } }
    const prepared = await this.prepareReportExportRouted(reportKey, objectKey, auditId, { ...options, scope })
    if ('blob' in prepared) {
      if (!prepared.download_token || !prepared.artifact_id || !prepared.expires_at) {
        throw new RuntimeApiError(502, { code: 'backend.report.export_legacy_projection_missing' }, 'Runtime did not publish the governed export compatibility headers')
      }
      this.preparedReportExportFiles.set(prepared.download_token, prepared)
      return {
        id: prepared.artifact_id,
        report_key: reportKey,
        object_key: objectKey,
        filename: prepared.filename ?? `${reportKey}-${objectKey}.csv`,
        token: prepared.download_token,
        expires_at: prepared.expires_at,
        content_sha256: prepared.content_sha256 ?? '',
        row_count: prepared.row_count ?? 0,
        scope,
        watermarked: true,
      }
    }
    let job = prepared
    const deadline = Date.now() + 5 * 60 * 1000
    while (job.status === 'accepted' || job.status === 'running') {
      if (Date.now() >= deadline) {
        throw new RuntimeApiError(504, { code: 'backend.report.export_legacy_wait_timeout' }, 'Legacy report export compatibility wait timed out')
      }
      await new Promise<void>((resolve) => setTimeout(resolve, 1000))
      job = await this.getReportExportJob(job.id, { requestId: options.requestId })
    }
    if (job.status !== 'completed' || !job.download_token || !job.expires_at) {
      throw new RuntimeApiError(409, { code: job.error_code ?? `backend.report.export_${job.status}` }, `Report export ended as ${job.status}`)
    }
    return {
      id: job.artifact_id ?? job.id,
      report_key: job.report_key,
      object_key: job.object_key,
      filename: `${job.report_key}-${job.object_key}.csv`,
      token: job.download_token,
      expires_at: job.expires_at,
      content_sha256: job.content_sha256 ?? '',
      row_count: job.rows_exported,
      scope: job.scope,
      watermarked: true,
    }
  }

  /** @deprecated Compile-time bridge for pre-governed adapters. */
  exportReportObject(
    reportKey: string,
    objectKey: string,
    options: { requestId?: string } = {},
  ): Promise<RuntimeReportExportFile> {
    return this.file(`/reports/${encodeURIComponent(reportKey)}/exports/${encodeURIComponent(objectKey)}`, {
      requestId: options.requestId,
    })
  }

  getReportExportJob(jobId: string, options: { requestId?: string } = {}) {
    return this.request<RuntimeReportExportJob>(`/report-exports/${encodeURIComponent(jobId)}`, { requestId: options.requestId })
  }

  cancelReportExport(jobId: string, options: { idempotencyKey: string; requestId?: string }) {
    return this.request<RuntimeReportExportJob>(`/report-exports/${encodeURIComponent(jobId)}/cancel`, {
      method: 'POST', requestId: options.requestId, headers: { 'Idempotency-Key': options.idempotencyKey },
    })
  }

  downloadReportExport(token: string, options: { requestId?: string } = {}) {
    const prepared = this.preparedReportExportFiles.get(token)
    if (prepared) {
      this.preparedReportExportFiles.delete(token)
      return Promise.resolve(prepared)
    }
    return this.file(`/report-exports/downloads/${encodeURIComponent(token)}`, {
      requestId: options.requestId,
    })
  }

  i18nResources(locale: string, namespace = '') {
    const params = new URLSearchParams({ locale: locale.trim() })
    if (namespace.trim()) params.set('namespace', namespace.trim())
    return this.request<RuntimeI18nResources>(`/i18n/resources?${params.toString()}`)
  }

  private notificationPath(suffix = '') {
    if (this.surface === 'business_workspace') return `/business/notifications${suffix}`
    if (this.surface === 'consumer_portal') return `/portal/notifications${suffix}`
    throw new Error('The Admin Console does not expose a personal notification inbox')
  }

  private notificationQuery(query: RuntimeNotificationQuery = {}) {
    const params = new URLSearchParams()
    if (query.scope) params.set('scope', query.scope)
    if (query.teamMemberId?.trim()) params.set('team_member_id', query.teamMemberId.trim())
    if (query.cursor?.trim()) params.set('cursor', query.cursor.trim())
    if (query.mailbox) params.set('mailbox', query.mailbox)
    if (query.query?.trim()) params.set('query', query.query.trim())
    query.categories?.forEach((value) => params.append('category', value))
    query.sources?.forEach((value) => params.append('source', value))
    query.severities?.forEach((value) => params.append('severity', value))
    query.actionStates?.forEach((value) => params.append('action_state', value))
    if (query.from) params.set('from', query.from)
    if (query.to) params.set('to', query.to)
    if (query.limit !== undefined) params.set('limit', String(query.limit))
    return params.size ? `?${params.toString()}` : ''
  }

  listNotifications(query: RuntimeNotificationQuery = {}) {
    return this.request<RuntimeNotificationPage>(
      `${this.notificationPath()}${this.notificationQuery(query)}`,
    )
  }

  getWebPushReadiness() {
    if (this.surface !== 'business_workspace') {
      throw new Error('Web Push self-service requires the business_workspace Surface')
    }
    return this.request<RuntimeWebPushReadiness>('/business/notifications/web-push/readiness')
  }

  listWebPushSubscriptions() {
    if (this.surface !== 'business_workspace') {
      throw new Error('Web Push self-service requires the business_workspace Surface')
    }
    return this.request<{ subscriptions: RuntimeWebPushSubscription[]; count: number }>(
      '/business/notifications/web-push/subscriptions',
    )
  }

  upsertWebPushSubscription(
    subscriptionID: string,
    request: RuntimeWebPushSubscriptionUpsertRequest,
    options: { idempotencyKey: string; requestId?: string },
  ) {
    if (this.surface !== 'business_workspace') {
      throw new Error('Web Push self-service requires the business_workspace Surface')
    }
    if (!subscriptionID.trim()) throw new Error('subscriptionID is required')
    if (!options.idempotencyKey.trim()) throw new Error('Idempotency-Key is required')
    return this.request<RuntimeWebPushSubscription>(
      `/business/notifications/web-push/subscriptions/${encodeURIComponent(subscriptionID)}`,
      {
        method: 'PUT',
        requestId: options.requestId,
        headers: { 'Idempotency-Key': options.idempotencyKey },
        body: request,
      },
    )
  }

  revokeWebPushSubscription(
    subscriptionID: string,
    options: { idempotencyKey: string; requestId?: string },
  ) {
    if (this.surface !== 'business_workspace') {
      throw new Error('Web Push self-service requires the business_workspace Surface')
    }
    if (!subscriptionID.trim()) throw new Error('subscriptionID is required')
    if (!options.idempotencyKey.trim()) throw new Error('Idempotency-Key is required')
    return this.request<RuntimeWebPushSubscription>(
      `/business/notifications/web-push/subscriptions/${encodeURIComponent(subscriptionID)}/revoke`,
      {
        method: 'POST',
        requestId: options.requestId,
        headers: { 'Idempotency-Key': options.idempotencyKey },
      },
    )
  }

  notificationFacets(query: RuntimeNotificationQuery = {}) {
    return this.request<RuntimeNotificationFacets>(
      `${this.notificationPath('/facets')}${this.notificationQuery(query)}`,
    )
  }

  notificationUnreadCount() {
    return this.request<{ unread: number }>(this.notificationPath('/unread-count'))
  }

  subscribeNotificationSync(
    onSync: (value: RuntimeNotificationSyncEvent) => void,
    options: RuntimeNotificationSyncOptions = {},
  ) {
    const controller = new AbortController()
    let cursor = options.cursor?.trim() ?? ''
    const retryDelayMs = Math.max(250, options.retryDelayMs ?? 1_000)
    const run = async () => {
      while (!controller.signal.aborted) {
        try {
          const headers = new Headers()
          headers.set(REQUEST_ID_HEADER, createRuntimeRequestID())
          headers.set(PRODUCT_SURFACE_HEADER, this.surface)
          headers.set('X-Workspace-ID', this.workspaceId)
          headers.set('Accept', 'text/event-stream')
          if (cursor) headers.set('Last-Event-ID', cursor)
          const accessToken = this.getAccessToken?.()
          if (accessToken) headers.set('Authorization', `Bearer ${accessToken}`)
          const response = await fetch(`${this.apiBaseUrl}${this.notificationPath('/stream')}`, {
            cache: 'no-store', headers, signal: controller.signal,
          })
          if (!response.ok) {
            const payload = await readRuntimePayload(response)
            throw new RuntimeApiError(response.status, payload, payload.message ?? payload.error ?? `Notification stream failed (${response.status})`)
          }
          if (!(response.headers.get('content-type') ?? '').includes('text/event-stream')) {
            throw new Error('Notification stream returned an invalid content type')
          }
          await consumeNotificationSyncStream(response, async (event, id, data) => {
            if (id) cursor = id
            if (event !== 'notification.sync') return
            const value = JSON.parse(data) as RuntimeNotificationSyncEvent
            if (value.cursor) cursor = value.cursor
            await options.refetch?.(value)
            onSync(value)
          }, controller.signal)
        } catch (error) {
          if (controller.signal.aborted) break
          options.onError?.(error)
        }
        await notificationReconnectDelay(controller.signal, retryDelayMs)
      }
    }
    void run()
    return () => controller.abort()
  }

  subscribeBusinessSync(
    onSync: (value: RuntimeBusinessSyncEvent) => void,
    options: RuntimeBusinessSyncOptions = {},
  ) {
    if (this.surface !== 'business_workspace') {
      throw new Error('Business record synchronization requires the Business Workspace surface')
    }
    const controller = new AbortController()
    let cursor = options.cursor?.trim() ?? ''
    const retryDelayMs = Math.max(250, options.retryDelayMs ?? 1_000)
    const run = async () => {
      while (!controller.signal.aborted) {
        try {
          const headers = new Headers()
          headers.set(REQUEST_ID_HEADER, createRuntimeRequestID())
          headers.set(PRODUCT_SURFACE_HEADER, this.surface)
          headers.set('X-Workspace-ID', this.workspaceId)
          headers.set('Accept', 'text/event-stream')
          if (cursor) headers.set('Last-Event-ID', cursor)
          const accessToken = this.getAccessToken?.()
          if (accessToken) headers.set('Authorization', `Bearer ${accessToken}`)
          const response = await fetch(`${this.apiBaseUrl}/business/records/stream`, {
            cache: 'no-store', headers, signal: controller.signal,
          })
          if (!response.ok) {
            const payload = await readRuntimePayload(response)
            throw new RuntimeApiError(response.status, payload, payload.message ?? payload.error ?? `Business sync stream failed (${response.status})`)
          }
          if (!(response.headers.get('content-type') ?? '').includes('text/event-stream')) {
            throw new Error('Business sync stream returned an invalid content type')
          }
          options.onStatus?.('connected')
          await consumeNotificationSyncStream(response, (event, id, data) => {
            if (id) cursor = id
            if (event !== 'business.sync') return
            const value = JSON.parse(data) as RuntimeBusinessSyncEvent
            if (value.cursor) cursor = value.cursor
            onSync(value)
          }, controller.signal)
        } catch (error) {
          if (controller.signal.aborted) break
          options.onStatus?.('reconnecting')
          options.onError?.(error)
        }
        await notificationReconnectDelay(controller.signal, retryDelayMs)
      }
      options.onStatus?.('disconnected')
    }
    void run()
    return () => controller.abort()
  }

  subscribeBusinessEvents(options: BusinessEventSubscriptionOptions): BusinessEventSubscription {
    if (this.surface !== 'business_workspace') {
      throw new Error('Business events require the Business Workspace surface')
    }
    if (typeof options.onEvent !== 'function') throw new Error('onEvent is required')
    const controller = new AbortController()
    let cursor = options.lastEventId?.trim() ?? ''
    let retryDelayMs = Math.max(250, options.initialRetryMs ?? 1_000)
    const maxRetryMs = Math.max(retryDelayMs, options.maxRetryMs ?? 30_000)
    let resolveClosed!: () => void
    const closed = new Promise<void>((resolve) => { resolveClosed = resolve })
    const externalAbort = () => controller.abort(options.signal?.reason)
    options.signal?.addEventListener('abort', externalAbort, { once: true })
    if (options.signal?.aborted) controller.abort(options.signal.reason)

    const run = async () => {
      options.onStateChange?.('connecting')
      while (!controller.signal.aborted) {
        try {
          const query = new URLSearchParams()
          if (options.objectKeys?.length) query.set('objects', options.objectKeys.join(','))
          if (options.eventTypes?.length) query.set('types', options.eventTypes.join(','))
          const headers = new Headers()
          headers.set(REQUEST_ID_HEADER, createRuntimeRequestID())
          headers.set(PRODUCT_SURFACE_HEADER, this.surface)
          headers.set('X-Workspace-ID', this.workspaceId)
          headers.set('Accept', 'text/event-stream')
          if (cursor) headers.set('Last-Event-ID', cursor)
          const accessToken = this.getAccessToken?.()
          if (accessToken) headers.set('Authorization', `Bearer ${accessToken}`)
          const suffix = query.size ? `?${query.toString()}` : ''
          const response = await fetch(`${this.apiBaseUrl}/events/business${suffix}`, {
            cache: 'no-store', headers, signal: controller.signal,
          })
          if (!response.ok) {
            const payload = await readRuntimePayload(response)
            throw new RuntimeApiError(response.status, payload, payload.message ?? payload.error ?? `Business event stream failed (${response.status})`)
          }
          if (!(response.headers.get('content-type') ?? '').includes('text/event-stream')) {
            throw new Error('Business event stream returned an invalid content type')
          }
          options.onStateChange?.('open')
          retryDelayMs = Math.max(250, options.initialRetryMs ?? 1_000)
          await consumeNotificationSyncStream(response, (eventName, id, data) => {
            if (id) cursor = id
            if (eventName !== 'business.refresh' && eventName !== 'business.resync') return
            const value = JSON.parse(data) as BusinessEvent
            if (id && !value.id) value.id = id
            if (value.id) cursor = value.id
            options.onEvent(value)
          }, controller.signal)
        } catch (error) {
          if (controller.signal.aborted) break
          options.onError?.(error)
        }
        if (controller.signal.aborted || options.reconnect === false) break
        options.onStateChange?.('reconnecting')
        await notificationReconnectDelay(controller.signal, retryDelayMs)
        retryDelayMs = Math.min(maxRetryMs, retryDelayMs * 2)
      }
      options.signal?.removeEventListener('abort', externalAbort)
      options.onStateChange?.('closed')
      resolveClosed()
    }
    void run()
    return {
      close: () => controller.abort(),
      closed,
      lastEventId: () => cursor,
    }
  }

  notificationPreference() {
    const path = this.surface === 'business_workspace'
      ? '/business/notification-preferences'
      : this.surface === 'consumer_portal'
        ? '/portal/notification-preferences'
        : undefined
    if (!path) throw new Error('The Admin Console does not expose personal notification preferences')
    return this.request<RuntimeNotificationPreference>(path)
  }

  saveNotificationPreference(value: Omit<RuntimeNotificationPreference, 'recipient_key' | 'updated_at'>) {
    const path = this.surface === 'business_workspace'
      ? '/business/notification-preferences'
      : this.surface === 'consumer_portal'
        ? '/portal/notification-preferences'
        : undefined
    if (!path) throw new Error('The Admin Console does not expose personal notification preferences')
    return this.request<RuntimeNotificationPreference>(path, { method: 'PUT', body: value })
  }

  getNotification(id: string, query: Pick<RuntimeNotificationQuery, 'scope' | 'teamMemberId'> = {}) {
    return this.request<RuntimeInboxNotification>(
      `${this.notificationPath(`/${encodeURIComponent(id)}`)}${this.notificationQuery(query)}`,
    )
  }

  setNotificationRead(id: string, read: boolean) {
    return this.request<RuntimeInboxNotification>(
      this.notificationPath(`/${encodeURIComponent(id)}/${read ? 'read' : 'unread'}`),
      { method: 'POST' },
    )
  }

  setNotificationArchived(id: string, archived: boolean) {
    return this.request<RuntimeInboxNotification>(
      this.notificationPath(`/${encodeURIComponent(id)}/${archived ? 'archive' : 'restore'}`),
      { method: 'POST' },
    )
  }

  acknowledgeNotificationAlert(id: string) {
    return this.request<RuntimeInboxNotification>(
      this.notificationPath(`/${encodeURIComponent(id)}/acknowledge`),
      { method: 'POST' },
    )
  }

  markAllNotificationsRead(query: RuntimeNotificationQuery = {}) {
    return this.request<{ updated: number }>(
      `${this.notificationPath('/read-all')}${this.notificationQuery(query)}`,
      { method: 'POST' },
    )
  }

  resolveNotificationAction(id: string, actionKey: string) {
    return this.request<RuntimeNotificationResolvedAction>(
      this.notificationPath(`/${encodeURIComponent(id)}/actions/${encodeURIComponent(actionKey)}/resolve`),
    )
  }

  listNotificationSavedViews() {
    return this.request<{ views: RuntimeNotificationSavedView[]; count: number }>(
      this.notificationPath('/saved-views'),
    )
  }

  saveNotificationSavedView(view: RuntimeNotificationSavedView) {
    return this.request<RuntimeNotificationSavedView>(
      this.notificationPath(`/saved-views/${encodeURIComponent(view.key)}`),
      { method: 'PUT', body: view },
    )
  }

  deleteNotificationSavedView(key: string) {
    return this.request<void>(
      this.notificationPath(`/saved-views/${encodeURIComponent(key)}`),
      { method: 'DELETE' },
    )
  }

  listNotificationDelegations() {
    return this.request<{ delegations: RuntimeNotificationDelegation[]; count: number }>(
      this.notificationPath('/delegations'),
    )
  }

  saveNotificationDelegation(value: RuntimeNotificationDelegation) {
    if (!value.id.trim()) throw new Error('delegation id is required')
    return this.request<RuntimeNotificationDelegation>(
      this.notificationPath(`/delegations/${encodeURIComponent(value.id)}`),
      { method: 'PUT', body: value },
    )
  }

  deleteNotificationDelegation(id: string) {
    return this.request<void>(
      this.notificationPath(`/delegations/${encodeURIComponent(id)}`),
      { method: 'DELETE' },
    )
  }

  listNotificationDelegatedOwners() {
    return this.request<{ owners: RuntimeNotificationDelegatedOwner[]; count: number }>(
      this.notificationPath('/delegated-owners'),
    )
  }
}

export function subscribeBusinessEvents(
  client: RuntimeClient,
  options: BusinessEventSubscriptionOptions,
): BusinessEventSubscription {
  return client.subscribeBusinessEvents(options)
}

export function runtimePermissionAllows(
  permissions: readonly string[],
  requiredPermission: string,
): boolean {
  const required = requiredPermission.trim()
  if (!required) return true
  if (permissions.includes('*') || permissions.includes(required)) return true
  const separator = required.indexOf('.')
  return separator > 0 && permissions.includes(`${required.slice(0, separator)}.*`)
}

export function runtimePermissionsAllow(
  permissions: readonly string[],
  requiredPermissions: readonly string[],
): boolean {
  return requiredPermissions.every((permission) =>
    runtimePermissionAllows(permissions, permission))
}

export function filterRuntimeActionsByPermission<
  TAction extends { requires_permission?: string },
>(actions: readonly TAction[], permissions: readonly string[]): TAction[] {
  return actions.filter((action) =>
    runtimePermissionAllows(permissions, action.requires_permission ?? ''))
}

export const RUNTIME_SESSION_KEYS = {
  business_workspace: 'domainry-business-runtime-session',
  admin_console: 'domainry-admin-runtime-session',
  consumer_portal: 'domainry-portal-runtime-session',
} as const satisfies Record<RuntimeProductSurface, string>

export class RuntimeSessionStore {
  readonly storageKey: string

  constructor(
    public readonly surface: RuntimeProductSurface,
    storageKey = RUNTIME_SESSION_KEYS[surface],
  ) {
    this.storageKey = storageKey
  }

  private storageFor(remember: boolean): Storage {
    return remember ? window.localStorage : window.sessionStorage
  }

  private readFrom(storage: Storage, remember: boolean): RuntimeSession | null {
    const raw = storage.getItem(this.storageKey)
    if (!raw) return null
    try {
      const parsed = JSON.parse(raw) as Partial<RuntimeSession>
      if (
        typeof parsed.accessToken !== 'string'
        || typeof parsed.refreshToken !== 'string'
        || typeof parsed.expiresAt !== 'string'
        || !parsed.user
        || !Array.isArray(parsed.roles)
      ) {
        storage.removeItem(this.storageKey)
        return null
      }
      return {
        ...parsed,
        remember,
      } as RuntimeSession
    } catch {
      storage.removeItem(this.storageKey)
      return null
    }
  }

  read(): RuntimeSession | null {
    if (typeof window === 'undefined') return null
    return this.readFrom(window.sessionStorage, false)
      ?? this.readFrom(window.localStorage, true)
  }

  persist(session: RuntimeSession) {
    const target = this.storageFor(session.remember)
    const other = this.storageFor(!session.remember)
    other.removeItem(this.storageKey)
    target.setItem(this.storageKey, JSON.stringify(session))
  }

  clear() {
    if (typeof window === 'undefined') return
    window.localStorage.removeItem(this.storageKey)
    window.sessionStorage.removeItem(this.storageKey)
  }
}
