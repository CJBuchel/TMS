-- Phase 5: the judging queue, pod timers, rubrics.

alter table judging_slots
  add column queue_state slot_queue_state not null default 'not_called',
  add column queue_previous slot_queue_state,
  add column queue_changed_at timestamptz,
  add column queue_changed_by text;

create table judging_queue_events (
  id bigserial primary key,
  slot_id uuid not null references judging_slots (id) on delete cascade,
  from_state slot_queue_state not null,
  to_state slot_queue_state not null,
  actor text not null,
  note text not null default '',
  at timestamptz not null default now()
);
create index judging_queue_events_slot on judging_queue_events (slot_id, at);

-- One timer per pod. A phase's end is phase_started_at + phase_ms; judges move between phases by hand.
create table pod_timers (
  pod_id uuid primary key references pods (id) on delete cascade,
  session_id uuid references judging_sessions (id) on delete set null,
  phase integer check (phase >= 0),
  phase_started_at timestamptz,
  phase_ms integer not null default 0 check (phase_ms >= 0),
  updated_at timestamptz not null default now()
);
create trigger pod_timers_updated_at before update on pod_timers for each row execute function set_updated_at();

create type rubric_status as enum ('submitted', 'accepted', 'rejected', 'superseded');

create table rubrics (
  id uuid primary key,
  event_id uuid not null references events (id) on delete cascade,
  event_code text not null,
  season_id text not null,
  schema_version integer not null,
  team_id uuid not null references teams (id) on delete restrict,
  slot_id uuid references judging_slots (id) on delete set null,
  pod_id uuid references pods (id) on delete set null,
  judge_names text not null default '',
  submitted_by_user uuid references users (id) on delete set null,
  submitted_by_key uuid references access_keys (id) on delete set null,
  submitted_by text not null,
  status rubric_status not null,
  duplicate boolean not null default false,
  scores jsonb not null,
  exceeds_comments jsonb not null default '{}',
  feedback jsonb not null default '{}',
  nominations text[] not null default '{}',
  innovation_project integer not null,
  robot_design integer not null,
  core_values_rows integer not null,
  review_note text not null default '',
  created_at timestamptz not null,
  received_at timestamptz not null default now(),
  reviewed_by text,
  reviewed_at timestamptz
);
create unique index rubrics_one_accepted_per_team on rubrics (team_id) where status = 'accepted';
create index rubrics_event_status on rubrics (event_id, status);
