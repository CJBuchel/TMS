-- Phase 1: teams, venue (tables, pods), schedule (matches, judging sessions, timetable blocks), event settings.

alter table events add column settings jsonb not null default '{}';

create table teams (
  id uuid primary key,
  event_id uuid not null references events (id) on delete cascade,
  number text not null check (length(number) between 1 and 12),
  name text not null check (length(name) between 1 and 120),
  affiliation text not null default '',
  pit text,
  notes text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (event_id, number)
);
create trigger teams_updated_at before update on teams for each row execute function set_updated_at();

-- Tables play in pairs by sort_order: 0 and 1 face each other, then 2 and 3.
create table game_tables (
  id uuid primary key,
  event_id uuid not null references events (id) on delete cascade,
  name text not null check (length(name) between 1 and 60),
  sort_order integer not null,
  unique (event_id, name)
);

create table pods (
  id uuid primary key,
  event_id uuid not null references events (id) on delete cascade,
  name text not null check (length(name) between 1 and 60),
  room text,
  sort_order integer not null,
  unique (event_id, name)
);

create type match_kind as enum ('practice', 'ranking');

create table game_matches (
  id uuid primary key,
  event_id uuid not null references events (id) on delete cascade,
  kind match_kind not null,
  number integer not null,
  scheduled_start timestamptz not null,
  scheduled_end timestamptz not null check (scheduled_end > scheduled_start),
  unique (event_id, kind, number)
);
create index game_matches_event_start on game_matches (event_id, scheduled_start);

-- A team or table in use by the schedule cannot be deleted out from under it.
create table match_slots (
  id uuid primary key,
  match_id uuid not null references game_matches (id) on delete cascade,
  table_id uuid not null references game_tables (id) on delete restrict,
  team_id uuid references teams (id) on delete restrict,
  round integer check (round > 0),
  unique (match_id, table_id)
);
create unique index match_slots_one_team_per_match on match_slots (match_id, team_id) where team_id is not null;
create index match_slots_team on match_slots (team_id);

create table judging_sessions (
  id uuid primary key,
  event_id uuid not null references events (id) on delete cascade,
  number integer not null,
  scheduled_start timestamptz not null,
  scheduled_end timestamptz not null check (scheduled_end > scheduled_start),
  unique (event_id, number)
);

create table judging_slots (
  id uuid primary key,
  session_id uuid not null references judging_sessions (id) on delete cascade,
  pod_id uuid not null references pods (id) on delete restrict,
  team_id uuid references teams (id) on delete restrict,
  unique (session_id, pod_id)
);
create unique index judging_slots_one_team_per_session on judging_slots (session_id, team_id) where team_id is not null;
create index judging_slots_team on judging_slots (team_id);

create type block_kind as enum ('break', 'ceremony', 'meeting', 'other');

create table schedule_blocks (
  id uuid primary key,
  event_id uuid not null references events (id) on delete cascade,
  kind block_kind not null,
  name text not null check (length(name) between 1 and 120),
  starts_at timestamptz not null,
  ends_at timestamptz not null check (ends_at > starts_at)
);

-- Access keys may be bound to the table or pod their device serves.
alter table access_keys
  add column table_id uuid references game_tables (id) on delete set null,
  add column pod_id uuid references pods (id) on delete set null;
