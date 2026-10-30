-- Phase 6: awards, deliberation, the awards ceremony.

create type award_kind as enum (
  'champions', 'core_values', 'innovation_project', 'robot_design', 'robot_performance', 'coach_mentor',
  'engineering_excellence', 'breakthrough', 'rising_all_star', 'motivate', 'peer', 'local'
);

-- The awards an event presents. sort_order is the ceremony order.
create table awards (
  id uuid primary key,
  event_id uuid not null references events (id) on delete cascade,
  kind award_kind not null,
  name text not null check (length(name) between 1 and 80),
  places integer not null check (places between 1 and 10),
  sort_order integer not null
);
create unique index awards_one_per_kind on awards (event_id, kind) where kind <> 'local';

create table award_winners (
  award_id uuid not null references awards (id) on delete cascade,
  team_id uuid not null references teams (id) on delete restrict,
  place integer not null check (place >= 1),
  note text not null default '',
  assigned_by text not null,
  assigned_at timestamptz not null default now(),
  primary key (award_id, place),
  unique (award_id, team_id)
);

create table advancements (
  event_id uuid not null references events (id) on delete cascade,
  team_id uuid not null references teams (id) on delete restrict,
  position integer not null check (position >= 1),
  primary key (event_id, team_id),
  unique (event_id, position)
);

-- Finalizing locks rubrics, awards and advancement; ceremony_shown counts the slides revealed so far.
create table deliberation_state (
  event_id uuid primary key references events (id) on delete cascade,
  finalized_at timestamptz,
  finalized_by text,
  ceremony_shown integer not null default 0 check (ceremony_shown >= 0)
);

insert into awards (id, event_id, kind, name, places, sort_order)
select gen_random_uuid(), e.id, k.kind, k.name, 1, k.sort_order
from events e
cross join (values
  ('coach_mentor'::award_kind, 'Coach/Mentor', 20),
  ('robot_performance', 'Robot Performance', 80),
  ('robot_design', 'Robot Design', 90),
  ('innovation_project', 'Innovation Project', 100),
  ('core_values', 'Core Values', 110),
  ('champions', 'Champion''s', 120)
) as k (kind, name, sort_order);
