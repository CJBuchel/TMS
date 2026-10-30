-- Phase 3: where each team is on its way to a match.

create type slot_queue_state as enum (
  'not_called', 'called', 'on_way', 'waiting', 'at_table', 'ready', 'running', 'done', 'no_show', 'scratched'
);

alter table match_slots
  add column queue_state slot_queue_state not null default 'not_called',
  add column queue_previous slot_queue_state,
  add column queue_changed_at timestamptz,
  add column queue_changed_by text;

-- Every change a person makes, with who made it. The match timer's own changes (running, done) are not listed;
-- the timer's audit entries cover them.
create table slot_queue_events (
  id bigserial primary key,
  slot_id uuid not null references match_slots (id) on delete cascade,
  from_state slot_queue_state not null,
  to_state slot_queue_state not null,
  actor text not null,
  note text not null default '',
  at timestamptz not null default now()
);
create index slot_queue_events_slot on slot_queue_events (slot_id, at);
