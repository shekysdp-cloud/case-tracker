-- =====================================================================
-- CASE TRACKER — SUPABASE SCHEMA
-- Run this entire file in Supabase → SQL Editor → New Query → Run.
-- Safe to re-run: uses IF NOT EXISTS where possible.
-- =====================================================================

-- ---------- Extensions ----------
create extension if not exists "pgcrypto";  -- for gen_random_uuid()

-- ---------- Enum types (dropdown value lists) ----------
do $$ begin
  create type client_type_t as enum (
    'Government Department','Municipality','School / SGB','Trade Union',
    'Private Company','NGO / NPO','Individual','Other'
  );
exception when duplicate_object then null; end $$;

do $$ begin
  create type service_line_t as enum (
    'Employee Relations','Labour Law','HR Advisory','School Safety',
    'SGB Governance','Training & Development','Investigations',
    'Policy Development','Mediation / Facilitation','Research & Compliance','Other'
  );
exception when duplicate_object then null; end $$;

do $$ begin
  create type priority_t as enum ('Low','Medium','High','Critical');
exception when duplicate_object then null; end $$;

do $$ begin
  create type project_status_t as enum (
    'Lead','Proposal Sent','Contracted','In Progress','On Hold','Completed','Cancelled'
  );
exception when duplicate_object then null; end $$;

do $$ begin
  create type matter_status_t as enum (
    'Open','In Progress','On Hold','Pending Outcome','Closed','Cancelled'
  );
exception when duplicate_object then null; end $$;

do $$ begin
  create type task_status_t as enum (
    'Not Started','In Progress','Blocked','Completed','Cancelled'
  );
exception when duplicate_object then null; end $$;

do $$ begin
  create type payment_status_t as enum (
    'Not Invoiced','Invoice Sent','Partially Paid','Paid','Overdue','Written Off'
  );
exception when duplicate_object then null; end $$;

do $$ begin
  create type staff_category_t as enum (
    'Public Servant','Educator','Private Sector Employee','SGB Member','Management','Other'
  );
exception when duplicate_object then null; end $$;

do $$ begin
  create type confidentiality_t as enum ('Standard','Privileged','Highly Restricted');
exception when duplicate_object then null; end $$;

do $$ begin
  create type lead_source_t as enum (
    'Referral','Website','LinkedIn','Networking','Existing Client',
    'Tender / RFP','Cold Outreach','Other'
  );
exception when duplicate_object then null; end $$;

do $$ begin
  create type lead_status_t as enum (
    'Lead','Proposal Sent','In Progress','Contracted','Completed','Cancelled'
  );
exception when duplicate_object then null; end $$;

do $$ begin
  create type relationship_status_t as enum ('Active','Dormant','Former Client','Prospect');
exception when duplicate_object then null; end $$;

do $$ begin
  create type matter_type_t as enum (
    'Disciplinary Hearing','Grievance','Dismissal Dispute',
    'CCMA / Bargaining Council Referral','Incapacity','SGB Governance Dispute',
    'Policy Advisory','Investigation','Mediation','Other'
  );
exception when duplicate_object then null; end $$;

do $$ begin
  create type document_type_t as enum (
    'Contract','Proposal','Invoice','Report','Policy','Training Material',
    'Legal Document','Correspondence','Meeting Record','Evidence','Other'
  );
exception when duplicate_object then null; end $$;

do $$ begin
  create type document_category_t as enum (
    'Policy','Legal Document / Agreement','Contract','Proposal','Invoice',
    'Report','Training Material','Correspondence','Meeting Record','Evidence','Other'
  );
exception when duplicate_object then null; end $$;

do $$ begin
  create type policy_type_t as enum (
    'Financial Policy','Learner Code of Conduct','Staff Code of Conduct',
    'Social Media Policy','Learner Discipline Policy','Safety Policy',
    'Contingency Policy','Business Continuity Policy','Inventory Policy',
    'Leave Management Policy','Other Policy'
  );
exception when duplicate_object then null; end $$;

do $$ begin
  create type legal_doc_type_t as enum (
    'Will / Wills','Lease Agreement','Lay-by Agreement','Acknowledgement of Debt',
    'Memorandum of Understanding (MOU)','Employment Contract','Other Legal Document / Agreement'
  );
exception when duplicate_object then null; end $$;

do $$ begin
  create type event_type_t as enum ('Workshop','Training Session','Seminar','Webinar','Other');
exception when duplicate_object then null; end $$;

-- ---------- Display-ID sequences (human-friendly IDs like MAT-2026-0001) ----------
create sequence if not exists seq_client_id;
create sequence if not exists seq_lead_id;
create sequence if not exists seq_project_id;
create sequence if not exists seq_matter_id;
create sequence if not exists seq_task_id;
create sequence if not exists seq_time_id;
create sequence if not exists seq_invoice_id;
create sequence if not exists seq_document_id;
create sequence if not exists seq_event_id;
create sequence if not exists seq_policy_id;
create sequence if not exists seq_legal_id;

-- ---------- CLIENTS ----------
create table if not exists clients (
  id uuid primary key default gen_random_uuid(),
  display_id text unique not null default ('CLI-' || lpad(nextval('seq_client_id')::text, 4, '0')),
  organisation_name text not null,
  client_type client_type_t not null,
  industry_sector text,
  contact_person text,
  email text,
  phone text,
  location text,
  date_onboarded date,
  relationship_status relationship_status_t not null default 'Active',
  lead_source lead_source_t,
  notes text,
  is_archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------- LEADS ----------
create table if not exists leads (
  id uuid primary key default gen_random_uuid(),
  display_id text unique not null default ('LEAD-' || lpad(nextval('seq_lead_id')::text, 4, '0')),
  date_received date not null,
  prospective_client text not null,
  client_type client_type_t not null,
  lead_source lead_source_t not null,
  service_required service_line_t not null,
  estimated_value_zar numeric(14,2),
  probability_pct integer check (probability_pct between 0 and 100),
  next_action_date date,
  lead_status lead_status_t not null default 'Lead',
  owner text,
  notes text,
  is_archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------- PROJECTS ----------
create table if not exists projects (
  id uuid primary key default gen_random_uuid(),
  display_id text unique not null default ('PRJ-' || lpad(nextval('seq_project_id')::text, 4, '0')),
  client_id uuid not null references clients(id) on delete restrict,
  service_line service_line_t not null,
  project_matter_name text not null,
  lead_consultant text,
  start_date date not null,
  target_end_date date,
  actual_end_date date,
  project_status project_status_t not null default 'In Progress',
  priority priority_t not null default 'Medium',
  contract_value_zar numeric(14,2),
  progress_pct integer check (progress_pct between 0 and 100),
  key_deliverable text,
  notes text,
  is_archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------- MATTERS ----------
create table if not exists matters (
  id uuid primary key default gen_random_uuid(),
  display_id text unique not null default ('MAT-' || extract(year from now())::text || '-' || lpad(nextval('seq_matter_id')::text, 4, '0')),
  project_id uuid references projects(id) on delete set null,
  client_id uuid not null references clients(id) on delete restrict,
  matter_type matter_type_t not null,
  subject_description text not null,
  staff_category staff_category_t not null,
  person_entity_concerned text not null,
  date_opened date not null,
  responsible_consultant text,
  matter_status matter_status_t not null default 'Open',
  priority priority_t not null default 'Medium',
  date_closed date,
  outcome text,
  confidentiality_level confidentiality_t not null default 'Privileged',
  notes text,
  is_archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------- TASKS / DEADLINES ----------
create table if not exists tasks (
  id uuid primary key default gen_random_uuid(),
  display_id text unique not null default ('TSK-' || lpad(nextval('seq_task_id')::text, 4, '0')),
  project_id uuid references projects(id) on delete set null,
  matter_id uuid references matters(id) on delete set null,
  client_id uuid not null references clients(id) on delete restrict,
  task_action text not null,
  assigned_to text,
  date_assigned date not null,
  due_date date not null,
  task_status task_status_t not null default 'Not Started',
  priority priority_t not null default 'Medium',
  completion_date date,
  notes text,
  is_archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------- TIME & BILLING ----------
create table if not exists time_entries (
  id uuid primary key default gen_random_uuid(),
  display_id text unique not null default ('TB-' || lpad(nextval('seq_time_id')::text, 4, '0')),
  entry_date date not null,
  project_id uuid not null references projects(id) on delete restrict,
  client_id uuid not null references clients(id) on delete restrict,
  consultant text,
  service_line service_line_t not null,
  description_of_work text not null,
  hours numeric(6,2) not null check (hours >= 0),
  rate_zar numeric(10,2) not null check (rate_zar >= 0),
  billable boolean not null default true,
  invoice_status payment_status_t not null default 'Not Invoiced',
  invoice_id uuid,
  notes text,
  is_archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------- INVOICES ----------
create table if not exists invoices (
  id uuid primary key default gen_random_uuid(),
  display_id text unique not null default ('INV-' || lpad(nextval('seq_invoice_id')::text, 4, '0')),
  invoice_date date not null,
  client_id uuid not null references clients(id) on delete restrict,
  project_id uuid not null references projects(id) on delete restrict,
  description text,
  invoice_amount_zar numeric(14,2) not null check (invoice_amount_zar >= 0),
  due_date date not null,
  payment_status payment_status_t not null default 'Invoice Sent',
  date_paid date,
  payment_reference text,
  notes text,
  is_archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- back-fill FK now that both tables exist
alter table time_entries
  drop constraint if exists time_entries_invoice_id_fkey,
  add constraint time_entries_invoice_id_fkey
    foreign key (invoice_id) references invoices(id) on delete set null;

-- ---------- DOCUMENTS ----------
create table if not exists documents (
  id uuid primary key default gen_random_uuid(),
  display_id text unique not null default ('DOC-' || lpad(nextval('seq_document_id')::text, 4, '0')),
  doc_date date not null,
  client_id uuid not null references clients(id) on delete restrict,
  project_id uuid references projects(id) on delete set null,
  matter_id uuid references matters(id) on delete set null,
  document_name text not null,
  document_type document_type_t not null,
  document_category document_category_t not null,
  legal_document_type legal_doc_type_t,
  policy_type policy_type_t,
  version text,
  author_owner text,
  storage_location_link text,
  confidentiality confidentiality_t not null default 'Standard',
  review_date date,
  status text,
  notes text,
  is_archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------- TRAINING & EVENTS ----------
create table if not exists training_events (
  id uuid primary key default gen_random_uuid(),
  display_id text unique not null default ('EVT-' || lpad(nextval('seq_event_id')::text, 4, '0')),
  event_date date not null,
  client_id uuid not null references clients(id) on delete restrict,
  event_type event_type_t not null,
  topic_programme text not null,
  facilitator text,
  participants_target_group text,
  fee_zar numeric(14,2),
  status text not null default 'Planned',
  feedback_outcome text,
  notes text,
  is_archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------- POLICY REGISTER ----------
create table if not exists policies (
  id uuid primary key default gen_random_uuid(),
  display_id text unique not null default ('POL-' || lpad(nextval('seq_policy_id')::text, 4, '0')),
  client_id uuid not null references clients(id) on delete restrict,
  policy_type policy_type_t not null,
  policy_title text not null,
  version text,
  date_drafted date,
  date_approved date,
  review_date date,
  responsible_consultant text,
  approval_status text not null default 'Draft',
  implementation_status text not null default 'Not Started',
  document_location_link text,
  notes text,
  is_archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------- LEGAL DOCUMENTS & AGREEMENTS ----------
create table if not exists legal_documents (
  id uuid primary key default gen_random_uuid(),
  display_id text unique not null default ('LGL-' || lpad(nextval('seq_legal_id')::text, 4, '0')),
  client_id uuid not null references clients(id) on delete restrict,
  document_type legal_doc_type_t not null,
  document_title_description text not null,
  parties text not null,
  responsible_consultant text,
  date_drafted date,
  date_signed_executed date,
  review_renewal_date date,
  status text not null default 'Draft',
  confidentiality confidentiality_t not null default 'Standard',
  document_location_link text,
  notes text,
  is_archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------- updated_at auto-touch trigger ----------
create or replace function touch_updated_at() returns trigger as $$
begin new.updated_at = now(); return new; end;
$$ language plpgsql;

do $$
declare t text;
begin
  for t in select unnest(array[
    'clients','leads','projects','matters','tasks','time_entries',
    'invoices','documents','training_events','policies','legal_documents'
  ]) loop
    execute format('drop trigger if exists trg_touch_%s on %I', t, t);
    execute format('create trigger trg_touch_%s before update on %I for each row execute function touch_updated_at()', t, t);
  end loop;
end $$;

-- ---------- ROW LEVEL SECURITY ----------
-- Initial policy: any authenticated user has full access. Tighten later
-- (e.g. per-consultant, per-confidentiality) once roles are decided.
do $$
declare t text;
begin
  for t in select unnest(array[
    'clients','leads','projects','matters','tasks','time_entries',
    'invoices','documents','training_events','policies','legal_documents'
  ]) loop
    execute format('alter table %I enable row level security', t);
    execute format('drop policy if exists "authenticated_all" on %I', t);
    execute format($p$create policy "authenticated_all" on %I
      for all to authenticated using (true) with check (true)$p$, t);
  end loop;
end $$;

-- ---------- Convenience view for the calendar (tasks + due_date) ----------
create or replace view v_calendar as
select
  t.id,
  t.display_id,
  t.task_action as title,
  t.due_date,
  t.task_status,
  t.priority,
  t.matter_id,
  t.client_id,
  c.organisation_name as client_name,
  m.display_id as matter_display_id
from tasks t
left join clients c on c.id = t.client_id
left join matters m on m.id = t.matter_id
where t.is_archived = false;

-- ---------- Done. ----------
