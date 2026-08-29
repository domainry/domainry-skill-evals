# Backend Dependency PRD

Project: M1 B2B Sales Lead CRM

Requirement authority: `requirements.md` (sole business input)

Frontend snapshot / commit: not applicable; no `frontend/src/**` exists

Batch: full

PRD mode: reference (`requirements.md` is structured; citations use its titled sections and numbered requirements)

Status: confirmed

## 1. Scope and evidence rules

- Backend scope: Business Workspace lead-to-customer CRM; lead management, approval conversion, department scope, reminders, reporting/export, audit, notification, navigation, acceptance fixtures.
- Managed Runtime database driver: `mysql`.
- Acceptance database driver: `same_as_managed_runtime`.
- Source document and citation scheme: `requirements.md §业务背景`; `§组织与角色`; `§功能需求.N`; `§范围限定`.
- Requirements evidence closure: this PRD + root `requirements.md`; no frontend evidence.
- Explicitly excluded frontend-only scope: all browser/UI implementation; Consumer Portal; external connectors; customer correction flow; commission/settlement.
- Accepted baseline reused by this delta: none; fresh project.
- Evidence precedence: explicit `requirements.md`; Skill domain-truth and published Runtime contracts supply only implementation mechanisms.
- Known conflicts: none.

Requirement classification is `confirmed` throughout. Runtime codes, canonical identities, cursor/fingerprint representation, and capability mapping remain contract discovery; deterministic reversible mechanisms are recorded in §11.

## 2. Actors, roles, and journeys

| Journey ID | Actor / role | Entry route | Preconditions | Steps and backend interactions | Observable success | Failure / recovery | Classification | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| J01 | East/ North sales / `sales_rep` | `business.my_leads` | formal acceptance session; department/workforce assignment | create lead with idempotency key; actor and department auto-bound | one `new` lead owned by actor; replay returns same effect | missing key rejected; conflicting replay unchanged | confirmed | requirements.md §功能需求.1,3,5 |
| J02 | owner / `sales_rep` | lead record | own `new/contacted/qualified` lead | update mutable contact fields; mark contacted/qualified/lost along declared edges | exact fields/state persisted; audit correlated | non-owner or illegal/terminal transition denied/conflict; unchanged | confirmed | requirements.md §功能需求.2-4,11,13 |
| J03 | owner / `sales_rep` | qualified lead | amount `<100000` | request conversion once | lead `converted` and exactly one customer atomically created | replay one customer; injected failure rolls back all | confirmed | requirements.md §功能需求.6-8 |
| J04 | owner then director | qualified lead | amount `>=100000` | request conversion; director approves pending approval | pending approval then atomic converted lead + customer; requester Inbox approval notification | duplicate request reuses pending/result; rollback unchanged | confirmed | requirements.md §功能需求.6-9 |
| J05 | owner then director | qualified lead | amount `>=100000` | request conversion; director rejects with reason | approval rejected; lead remains `qualified`; requester Inbox rejection notification | non-director denied; missing reason rejected; unchanged | confirmed | requirements.md §功能需求.6,7,9 |
| J06 | sales / `sales_rep` | lead list/detail | two departments with distinguishable records | query own department and same-department peer record | bounded non-empty department result | cross-department same-record concealed; mutation by peer denied unchanged | confirmed | requirements.md §组织与角色; §功能需求.11 |
| J07 | director / `sales_director` | all leads | records in both departments | query list/detail | non-empty cross-department result | sales report/full-scope request denied | confirmed | requirements.md §功能需求.12,15 |
| J08 | scheduler service | weekday morning schedule | contacted lead with status age >7 days; reminder absent for date | scan one bounded batch and dispatch reminder intent | requester Inbox reminder; one durable `(lead,date)` reminder record | replay/restart produces no duplicate | confirmed | requirements.md §功能需求.14 |
| J09 | director / `sales_director` | `business.reports` | seeded leads across states/departments | execute funnel Report | each state count and exact amount sum reconcile to lead facts | sales denied; no report result exposed | confirmed | requirements.md §功能需求.15 |
| J10 | director / `sales_director` | report/export | authorized filters | prepare governed detail export from same paged Report | requester-only audited CSV; threshold routing and replay contracts hold | sales/download-scope drift denied; no duplicate artifact | confirmed | requirements.md §功能需求.16 |
| J11 | sales/director | lead list | more than one distinguishable lead/equal sort keys | traverse signed cursor pages | bounded pages; deterministic no duplicate/gap result | oversized/stale cursor rejected | confirmed | requirements.md §功能需求.17 |
| J12 | all application roles | Business Workspace | formal non-human identities and menu bootstrap | login; load effective menus | sales sees My Leads; director sees All Leads + Reports | no cross-role extra menus | confirmed | requirements.md §功能需求.18,19 |

## 3. Routes and page dispositions

No frontend routes exist. Backend route identities are selected only from the pinned Runtime contract after capability discovery.

| Route / page | Visible purpose | Backend-bound states and operations | Requirement IDs | Disposition | Evidence |
| --- | --- | --- | --- | --- | --- |
| `business.my_leads` | sales lead workspace | bounded list/detail; create/update/status/convert | CRM-01..CRM-11, CRM-17 | metadata + Actions + Runtime CRUD/query | requirements.md §功能需求.1-11,17 |
| `business.all_leads` | director lead workspace | full-scope bounded list/detail; approvals | CRM-06..CRM-13, CRM-17 | metadata + Actions + Runtime query | requirements.md §功能需求.6-13,17 |
| `business.reports` | director reporting | funnel run; governed detail export | CRM-15..CRM-17 | Reports + export controls | requirements.md §功能需求.15-17 |

## 4. Domain objects and data contract

| Requirement ID | Object / concept identity | Fields and units | Relations / cardinality | Query, filter, sort, pagination | Sensitive data | Classification | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| CRM-01..05 | `lead` | company required; contact; phone sensitive; expected_amount exact decimal(18,2); source enum; state; owner; department; status_changed_at; timestamps | owner→Identity user many:one; department→Identity department many:one | department/all scope; filters state/source/owner/department; updated_at desc + id; page max 200 | phone hidden from unauthorized scope and excluded from sales export | confirmed | requirements.md §功能需求.1-5 |
| CRM-06..09 | `conversion_approval` | status pending/approved/rejected; request key; decision reason; requested/decided timestamps | approval→lead many:one; requester/director→Identity user many:one | pending by created_at asc + id; max 200 | reason limited to scoped actors/director | confirmed | requirements.md §功能需求.6-9 |
| CRM-07..10 | `customer` | company; contact; expected_amount decimal(18,2); source; created_at | customer→source lead one:one; owner/department snapshot relations | read-only; created_at desc + id; max 200 | contact/phone follow lead sensitivity | confirmed | requirements.md §功能需求.7,10 |
| CRM-14 | `lead_reminder_delivery` | reminder_date; status; sent_at | reminder→lead many:one; recipient→Identity user many:one | unique workspace+lead+date; bounded schedule batch | recipient-only notification linkage | confirmed | requirements.md §功能需求.14 |

## 5. Commands, state, and durable effects

| Requirement ID | Command / transition | Target and preconditions | Input / output | Authorization and scope | Transaction boundary | Idempotency / concurrency | Durable and external effects | Errors / conflicts | Classification | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| CRM-03,05 | `create_lead` | actor has department/workforce profile | business fields / lead ref | sales; actor department auto-bound | one Runtime UoW including audit | required key; same payload replay; different payload conflict | one `new` lead + audit | validation/auth/idempotency stable categories | confirmed | requirements.md §功能需求.3,5 |
| CRM-03,11 | `update_lead` | owner; nonterminal lead; expected version | mutable fields / updated lead | sales owner-only; director has read, not this sales command | lock/CAS update + audit | required key; updated_at CAS | lead update + audit | non-owner denied; stale conflict; invalid amount/source rejected | confirmed | requirements.md §功能需求.3,11,13 |
| CRM-02,04,11 | `mark_contacted`, `mark_qualified`, `mark_lost` | owner; declared source state | target/reason where applicable / lead | sales owner-only | lock/CAS state + status_changed_at + audit | required key per mutation; terminal replay only exact receipt | state transition + audit | illegal/terminal conflict; non-owner denied | confirmed | requirements.md §功能需求.2,4,11,13 |
| CRM-06..09 | `request_conversion` | owner; qualified; no completed customer | request key / direct result or pending approval | owner sales | direct: lead+customer+audit; high: approval+audit | key + unique source lead/customer; lock lead | low customer+converted; high pending approval | threshold exact; duplicate conflict/replay without second customer | confirmed | requirements.md §功能需求.6-9 |
| CRM-07,09 | `approve_conversion` | director; pending approval; qualified lead | approval ref / customer ref | director all scope | approval+lead+customer+audit+notification intent atomically | key; lock/CAS approval+lead; unique source lead | approved, converted, customer, requester notification | duplicate decision replay; competing reject conflicts unchanged | confirmed | requirements.md §功能需求.7-9,13 |
| CRM-07,09 | `reject_conversion` | director; pending approval; non-empty reason | approval ref+reason / rejected approval | director all scope | approval+reason+audit+notification intent atomically | key; lock/CAS approval; competing approve conflicts | rejected; lead remains qualified; requester notification | missing reason rejected; duplicate decision replay | confirmed | requirements.md §功能需求.7,9,13 |
| CRM-10 | customer mutation | existing customer | none | no business role | prohibited | not applicable | no update/delete | permission denied unchanged | confirmed | requirements.md §功能需求.10 |
| CRM-14 | `send_stale_lead_reminders` | weekday run date; contacted age >7 days | run_date / counts | scheduler run-as governed role | reminder rows + notification intents per accepted batch | run_date key; unique lead/date; fenced scheduled run | Inbox reminder once/day + audit | duplicate/restart replay; bounded next batch | confirmed | requirements.md §功能需求.14 |

## 6. Calculations and policy versions

| Requirement ID | Fact type | Result | Inputs and units | Formula | Calculation Owner | Evaluation Time | Persisted Result | Policy/Rule Snapshot | Input Snapshot | Calculation Trace | Rounding point and mode | Correction/Reversal Strategy | Downstream Consumers | Report Source of Truth | Worked examples | Classification | Confirmation evidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| CRM-06 | occurred | direct vs approval-required conversion route | lead expected_amount decimal(18,2); threshold 100000.00 | `<100000.00` direct; otherwise approval | `request_conversion` Action | locked command time | approval presence or converted lead/customer | fixed requirement threshold identity | lead ID, amount, version | branch + affected record IDs in audit | exact decimal compare; no rounding | no mutation after terminal; future correction flow excluded | lead/customer/approval/audit | persisted command facts | 99999.99 direct; 100000.00 approval | confirmed | requirements.md §功能需求.6; §范围限定 |
| CRM-15 | summary | per-state lead count and expected amount sum | persisted lead state + decimal amount | group by state; count; exact sum | `lead_funnel` Report | read time under director Scope | no new occurred fact | current Report SQL/source hash | normalized filters + Scope | query/pagination/profile evidence | sum at stored scale 2, no conversion | source lead corrections affect current summary | report view | scoped `lead` rows | two 100000.00 leads => 200000.00 | confirmed | requirements.md §功能需求.15; §范围限定 |
| CRM-16 | summary/export | authorized lead-detail CSV | persisted lead fields | row projection only | `lead_detail_export` Report/export substrate | prepare/worker read time | governed artifact + exact total | Report SQL/source hash + normalized params/Scope | requester/workspace/filters/scope | job/audit/artifact correlation | preserve decimal scale 2 | expired/failed artifacts may create one new execution | director download | same paged Report | 1000 sync; 1001 async | confirmed | requirements.md §功能需求.16 |

There are no settlement, commission, payroll, inventory-cost, ratio, or simulation facts. Customer amount is an event-time snapshot created by the conversion Action; later lead edits are disallowed after terminal conversion and customer correction is outside scope.

## 7. Authorization, data scope, and navigation

| Requirement ID | Role / actor | Permission | Record/data scope | Sensitive-field policy | Menu / route expectation | Allowed proof | Denied proof | Classification | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| CRM-03..05,11 | `sales_rep` | lead create; owner update/status/convert; lead read | department read; Handler-enforced owner writes | phone/contact only within visible lead scope; no export | My Leads | same-department peer read + own mutation | cross-department same-record concealment; peer mutation denied unchanged | confirmed | requirements.md §组织与角色; §功能需求.3-5,11,18 |
| CRM-06..18 | `sales_director` | all lead/customer read; approval decide; Reports/export | all workspace departments | governed export; requester-only artifact | All Leads + Reports | both departments; approve/reject; report/export | sales report/export denied | confirmed | requirements.md §组织与角色; §功能需求.6-18 |
| CRM-10 | all business roles | customer read where permitted; no update/delete permissions | director all; originating sales department read only if modeled by declared scope | inherited contact sensitivity; sales export denied | no separate required menu | created customer readback through authorized actor | update/delete denied unchanged | confirmed | requirements.md §功能需求.7,10-12 |

## 8. Reports, schedules, notifications, files, and integrations

| Requirement ID | Capability | Owner / trigger / schedule | Inputs | Durable output / audit | External effect | Identity / allowlist / retry / reconciliation | Permission / scope | Classification | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| CRM-09 | approval result Inbox | approve/reject terminal event | requester + approval/lead/result | durable Inbox/outbox/audit correlation | none | requester only; after commit; replay once | approval actor/requester visibility | confirmed | requirements.md §功能需求.9 |
| CRM-14 | weekday stale reminder | Scheduler → Action; weekday morning, deployment timezone | run_date; contacted age >7 days | reminder-delivery unique row + Inbox/outbox/audit | none | recipient only; bounded batch; retry/restart/fencing | scheduler governed role; lead department scope recovered | confirmed | requirements.md §功能需求.14 |
| CRM-15 | `lead_funnel` Report | director on demand | optional department/source/date filters | audit + page/query profile evidence | none | exact SQL/source hash | director all scope | confirmed | requirements.md §功能需求.15 |
| CRM-16 | `lead_detail_export` Report/export | director prepare; Runtime export worker over threshold | normalized filters; current Scope | audit/job/artifact/download; terminal exact total | governed CSV only | canonical fingerprint; requester-only; current persisted reauthorization | director; current all-scope filter | confirmed | requirements.md §功能需求.16 |

No Agent task, external Connector, Consumer Portal, file upload/import, or external channel is in scope.

| Requirement ID / Report key | Result kind | Page contract | Maximum page size + decision source | Stable sort and cursor tie-breaker | `truncated` semantics | Threshold probe / exact total | `<=1000` synchronous | `>1000` async job | Canonical fingerprint/replay identity | Async notification links | Download identity / Scope / expiry / audit | Runtime support or owner gap | Evidence |
| --- | --- | --- | ---: | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| CRM-15 / `lead_funnel` | aggregate list | signed opaque cursor | 200 safe default; natural max 5 states | state ordinal + stable state key | true only when another authorized row exists | same Report; exact exhausted total | governed result; export not required | substrate applicable only if threshold exceeded | Report+params+SQL+requester/workspace+Scope+format+version | async only if routed | requester/Scope/expiry/audit | discover Reports category | requirements.md §功能需求.15 |
| CRM-16 / `lead_detail_export` | detail list/export | signed opaque cursor | 200 safe default | updated_at desc + lead ID desc | true iff next authorized row exists | one same-Report probe through row 1001; terminal exact total | exhausted 0..1000 governed CSV | row 1001 routes to paged accepted/running/completed/failed/cancelled job | Report+normalized params+SQL hash+requester/workspace+authorization/data Scope+CSV+result version; exclude audit_id | requester Inbox `completed`/`failed` → audit/job/artifact | current requester+workspace+Scope; expiry+integrity+audit | discover Reports/export category | requirements.md §功能需求.16 |

Async worker reconstructs the current persisted project user-role principal in the frozen workspace through the formal Runtime identity path, compares the canonical Scope hash, and fails closed only on real assignment/Scope drift. Transport reconstruction never substitutes a manifest-only role or synthetic surface.

## 9. Errors, empty/loading states, and recovery

| Requirement ID | Operation | Validation error | Permission / hidden scope | Conflict / concurrency | Transport / retry | Empty/loading behavior | Stable code or category | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| CRM-01..05 | lead create/update/transition | required company; enum/decimal/phone validation; legal transition | cross-department concealed; non-owner mutation denied | CAS stale; idempotency payload conflict | same key replay; no duplicate | empty page is explicit exhausted result | discover Runtime validation/auth/conflict codes | requirements.md §功能需求.1-5,11 |
| CRM-06..09 | conversion/decision | qualified/pending/reason/threshold preconditions | non-owner/director denial | one terminal decision/customer; competing decision conflict | replay original receipt across restart | missing approval is setup failure, not pass | discover Runtime/action business codes | requirements.md §功能需求.6-9 |
| CRM-14 | reminder schedule | invalid run date rejected | run-as scope recovered | duplicate lead/date no second reminder | fenced retry/restart | zero eligible leads is valid only with proven setup | discover Scheduler/Action codes | requirements.md §功能需求.14 |
| CRM-15..17 | list/report/export | page max/cursor/filter validation | sales report/export denied; requester-only artifact | stale cursor or scope drift conflict | replay fingerprint; worker retry | explicit zero rows/metrics, never setup accident | discover Report/export codes | requirements.md §功能需求.15-17 |

## 10. Runtime and metadata traceability

| Requirement ID | Demand evidence | Runtime owner / capability | Fixed category / route | Model resource or source gap | Permission / scope | Acceptance journey | Disposition | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| CRM-01 | §功能需求.1 | Object/field/relation | CRUD category | `lead` | scoped read | J01/J06 | metadata | confirmed |
| CRM-02 | §功能需求.2 | state + Actions | CRUD/state category | lead states + owner Actions | owner write | J02 | approved source gap | confirmed |
| CRM-03 | §功能需求.3 | Action/data capabilities | Actions category | create/update Handlers | owner/department | J01/J02 | approved source gap | confirmed |
| CRM-04 | §功能需求.4 | Actions/state | Actions category | state Handlers | owner write | J02 | approved source gap | confirmed |
| CRM-05 | §功能需求.5 | Action idempotency | Actions category | create Handler | sales | J01 | approved source gap | confirmed |
| CRM-06 | §功能需求.6 | Action + approval workflow | Actions/Workflow category | conversion + approval | owner/director | J03-J05 | approved source gap | confirmed |
| CRM-07 | §功能需求.7 | atomic Actions | Actions category | approve/reject Handlers | director | J04/J05 | approved source gap | confirmed |
| CRM-08 | §功能需求.8 | idempotency/uniqueness | Actions category | conversion constraints | owner/director | J03/J04 | approved source gap | confirmed |
| CRM-09 | §功能需求.9 | notifications/outbox | Notification category | Action intents | requester-only | J04/J05 | platform reused | confirmed |
| CRM-10 | §功能需求.10 | immutable permissions | CRUD category | customer deny mutation | scoped read | J03/J04 | metadata | confirmed |
| CRM-11 | §功能需求.11 | department data scope + owner Handler | identity/data scope | roles + Actions | department/owner | J02/J06 | metadata + source | confirmed |
| CRM-12 | §功能需求.12 | all-record scope | identity/data scope | director role | all | J07 | metadata | confirmed |
| CRM-13 | §功能需求.13 | Runtime audit | audit category | Action audit events | mutation actors | J02-J05 | platform reused | confirmed |
| CRM-14 | §功能需求.14 | Scheduler + Action + notifications | Scheduler/Notification category | reminder Action/job/object | owner | J08 | metadata + source | confirmed |
| CRM-15 | §功能需求.15 | Object SQL Report | Reports category | `lead_funnel` SQL | director all | J09 | metadata + SQL | confirmed |
| CRM-16 | §功能需求.16 | governed Report export | Reports/export category | `lead_detail_export` + controls | director/requester | J10 | metadata + SQL | confirmed |
| CRM-17 | §功能需求.17 | object query pagination | CRUD/read category | lead list contract/index | role scope | J11 | platform reused | confirmed |
| CRM-18 | §功能需求.18 | effective menus | identity/menu category | bootstrap menus/bindings | role | J12 | metadata | confirmed |
| CRM-19 | §功能需求.19 | bootstrap identities/seeds | identity/evidence | demo users + seeds | test-only | J01-J12 | metadata | confirmed |

### Coverage totals

| Frontend routes | Routes dispositioned | Typed API operations | Operations traced | Write operations | Writes with auth + transaction + idempotency + error contract | Open critical rules |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 0 | 0 | 0 before capability discovery | 0 before capability discovery | 8 business commands | 8 | 0 |

## 11. Decisions and open questions

| Decision ID | Affected requirements | Topic | Decision class | Observable business invariant | Assumption, discovered contract, or safe default | Decision owner | Confirmation / review trigger | Excluded acceptance scope / evolution path |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| D01 | CRM-01,06,15 | amount currency/unit unspecified | safe_implementation_decision | exact two-decimal comparison and sum | decimal(18,2); no currency conversion; optional currency absent | backend | revisit if multi-currency required | conversion/reporting migration |
| D02 | CRM-06,07 | pending state absent from lead lifecycle | safe_implementation_decision | lead changes only on terminal approval effect | independent pending approval Object; lead stays qualified | backend | revisit if product adds pending lead state | lifecycle evolution |
| D03 | CRM-14 | timezone/holiday calendar unspecified | product_follow_up | once each weekday morning | deployment-configured deterministic timezone; 09:00 Mon-Fri; no holiday calendar | product | review on multi-timezone/holiday demand | calendar policy |
| D04 | CRM-15..17 | page maximum/cursor mechanics | safe_implementation_decision | bounded deterministic traversal | max 200; signed opaque cursor; explicit stable tie-breaker; exact total where emitted | Runtime/backend | change only by versioned contract | cursor version |
| D05 | CRM-05,08,14,16 | Runtime error/cursor/fingerprint representations | contract_discovery | stable reason-specific observable result | use only published contract values, carried unchanged | Runtime | capability discovery | affected acceptance waits on formal source |
| D06 | CRM-10 | customer correction unspecified and excluded | product_follow_up | customer immutable in this release | no update/delete grants or Actions | product | new correction requirement | append-only correction workflow |
| D07 | CRM-14 | “status unchanged” source | safe_implementation_decision | eligibility depends on state age, not unrelated contact edits | persist `status_changed_at`; compare to run time minus 7 days | backend | change only with explicit inactivity policy | reminder policy version |
| D08 | CRM-16 | export replay/notification mechanics | safe_implementation_decision | no duplicate work/artifact/notification | platform standard canonical compare-and-create; audit_id excluded | Runtime | Reports contract discovery | platform evolution |

No `business_blocker` exists.

## 12. Acceptance contract

All actors are project-declared non-human identities. `GET /identity/principal-context`, seed/admin responses, and persisted Runtime results are the only sources for canonical identity/scope values; values are carried unchanged.

| Journey / requirement | Actor | Formal identity / context source | Fresh setup and dependencies | Command + actor-visible read | Positive oracle | Same-record scope contrast | Exact negative oracle + unchanged state | Durable effect / reconciliation | Restart / replay proof | Runtime/API evidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| J01 / CRM-01,03,05 | east sales | demo-user login → principal-context | unique namespace; no prior key | create Action → lead detail | returned lead ID; company non-empty; new/owner/department exact | north sales probes same lead | concealed/denied category; no row delta | lead row + audit + action receipt | same key/payload after restart one row | HTTP, persistence, idempotency, audit |
| J02 / CRM-02,04,11,13 | owning east sales | principal-context | fresh owned and peer leads | update/state Actions → detail | exact target and next state/fields | peer sales probes owner lead | permission/ownership denial or illegal-state conflict; durable hash unchanged | lead version/status_changed_at + audit | receipt replay; terminal conflict persists | HTTP, transaction, persistence, audit |
| J03 / CRM-06..08 | owning sales | principal-context | fresh qualified 99999.99 lead | conversion Action → lead/customer read | same lead converted; exactly one linked customer with non-empty company | peer/cross-dept probes same lead | denied/concealed; no customer | atomic rows + audit correlation | replay/restart same customer ID | HTTP, transaction, persistence, idempotency |
| J04 / CRM-06..09 | owner + director | both principal-contexts | fresh qualified 100000.00 lead | request then approve → approval/lead/customer/Inbox | pending approval ID then approved; converted; one customer; requester notification | non-director probes approval Action | denied unchanged pending; competing reject conflict unchanged after approve | approval+lead+customer+audit+notification chain | request/decision replay and restart no duplicate | HTTP, transaction, Inbox durable refetch, audit |
| J05 / CRM-06,07,09 | owner + director | both principal-contexts | fresh qualified 150000.00 lead | request then reject → approval/lead/Inbox | rejected with non-empty reason; lead qualified; requester notification | non-director decision probe | denied unchanged; missing reason rejected unchanged | approval reason + audit + notification | decision replay after restart one notification | HTTP, persistence, Inbox, audit |
| J06 / CRM-11 | east and north sales | principal-context department selectors | colliding named leads in both departments | object query/detail + mutation | east sees own + east peer non-empty | north probes exact east target | concealed read and denied mutation; unchanged row | scoped query facts | session/restart scope unchanged | HTTP + differentiated-scope data |
| J07 / CRM-12,15 | director + sales | principal-context | same records from J06 or isolated equivalents | full query/report | director observes exact east+north targets | sales probes report | stable permission denial; no report data/artifact | read/audit facts | director session and result valid after restart | HTTP, report, scope evidence |
| J08 / CRM-14 | scheduler/recipient | scheduler run-as + recipient principal-context | fresh contacted lead with old status_changed_at; run_date namespace | scheduled Action → recipient notifications | target lead reminder with non-empty linkage | other sales notification list | concealment; no cross-recipient row | reminder unique row + outbox/audit | same run/restart one effect; worker terminal | Scheduler, worker, Inbox, persistence |
| J09 / CRM-15 | director | principal-context | isolated seeded state/amount set | Report → report page | exact per-state non-zero counts/sums matching target IDs | sales same parameters | permission denial; no artifact | Report SQL/source/scope + query profile | identical result after Runtime restart | report HTTP, pagination/query profile |
| J10 / CRM-16 | director requester | principal-context | 0/1000/1001 isolated cohorts | export prepare/status/download | correct branch; exact total; valid CSV containing target row | sales/other requester probes same job/artifact | permission/requester/scope denial; unchanged job | audit/job/artifact/download + async notification | canonical replay and worker restart one artifact | export HTTP, worker, query profile, audit |
| J11 / CRM-17 | sales/director | principal-context | equal updated_at distinguishable leads over pages | object query cursor traversal | target IDs exactly once; page <=200; truncated/total exact | cross-dept actor same cursor/query | scope/cursor denial or stale conflict; no leakage | pagination trace + MySQL EXPLAIN JSON | cursor replay deterministic | HTTP pagination, query profile |
| J12 / CRM-18,19 | east sales, north sales, director | demo login → principal-context | bootstrap identities, workforce assignments, departments, roles, menus | effective-menu list | exact role menu key/route set non-empty | compare all roles | missing/unexpected menu count zero | persisted role/menu assignments | sessions/menu truth after restart | Identity HTTP + supported DB inspection |

Highest-risk canary: J04, because it crosses two authenticated principals, department/all scope, two Handler Actions, approval state, atomic multi-record persistence, notification/outbox, audit, idempotency, conflict, and actor-visible readback.

## Confirmation

- [x] All routes are dispositioned (no frontend; three backend menu routes mapped).
- [x] Every backend-bound typed API operation will be traced after fixed capability discovery; no pre-discovery route was invented.
- [x] Every write operation defines authorization, transaction, idempotency/concurrency, errors, and durable effects.
- [x] Every unresolved decision is classified; no business blocker exists.
- [x] Occurred facts and summaries are separated; no simulation or settlement fact exists.
- [x] Historical conversion/customer facts use event-time snapshots; Reports sum current lead facts only.
- [x] Every list Report has bounded server pagination and deterministic ordering.
- [x] Export uses same-Report threshold routing, fingerprint replay, requester notification, and reauthorization contracts.
- [x] Frontend-only behavior is explicitly excluded.
- [x] Every journey binds formal actor context, isolated setup, strict positive/negative oracles, and reconciliation.
- [x] Scope-sensitive journeys use same-target differentiated sessions and unchanged-state negatives.
- [x] Traceability and acceptance matrices cover CRM-01 through CRM-19.
