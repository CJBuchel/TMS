-- Phase 2: match state, the match timer, scoresheets.

create type match_state as enum ('scheduled', 'staged', 'running', 'finished', 'cancelled');

alter table game_matches
  add column state match_state not null default 'scheduled',
  add column started_at timestamptz,
  add column finished_at timestamptz;
create index game_matches_event_state on game_matches (event_id, state);

create type timer_phase as enum ('idle', 'countdown', 'running', 'endgame', 'ended', 'aborted');

-- One match timer per event. `starts_at` is when match time zero is (after any countdown), so every phase
-- follows from it and the clock. `run_id` changes on every start and abort; a timer task only writes while its
-- run is current, so an aborted run can never end a later one.
create table match_timers (
  event_id uuid primary key references events (id) on delete cascade,
  run_id uuid not null,
  phase timer_phase not null default 'idle',
  starts_at timestamptz,
  countdown_ms integer not null check (countdown_ms >= 0),
  duration_ms integer not null check (duration_ms > 0),
  endgame_ms integer not null check (endgame_ms >= 0),
  match_ids uuid[] not null default '{}',
  updated_at timestamptz not null default now()
);
create trigger match_timers_updated_at before update on match_timers for each row execute function set_updated_at();

create type scoresheet_status as enum ('submitted', 'published', 'rejected', 'superseded');

-- `id` is made by the device, so sending the same sheet twice stores it once.
create table scoresheets (
  id uuid primary key,
  event_id uuid not null references events (id) on delete cascade,
  event_code text not null,
  season_id text not null,
  schema_version integer not null,
  team_id uuid not null references teams (id) on delete restrict,
  kind match_kind not null,
  round integer not null check (round > 0),
  match_id uuid references game_matches (id) on delete set null,
  slot_id uuid references match_slots (id) on delete set null,
  table_id uuid references game_tables (id) on delete set null,
  submitted_by_user uuid references users (id) on delete set null,
  submitted_by_key uuid references access_keys (id) on delete set null,
  submitted_by text not null,
  referee_name text not null default '',
  status scoresheet_status not null,
  flags text[] not null default '{}',
  no_show boolean not null default false,
  score integer not null check (score >= 0),
  gp smallint check (gp between 2 and 4),
  gp_comment text not null default '',
  answers jsonb not null,
  issues jsonb not null default '[]',
  team_agreed boolean not null default false,
  team_initials text not null default '',
  private_comment text not null default '',
  review_note text not null default '',
  created_at timestamptz not null,
  received_at timestamptz not null default now(),
  reviewed_by text,
  reviewed_at timestamptz
);
create unique index scoresheets_one_published_per_round on scoresheets (team_id, kind, round) where status = 'published';
create index scoresheets_event_status on scoresheets (event_id, status);
create index scoresheets_slot on scoresheets (slot_id);
