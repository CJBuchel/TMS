-- Phase 0: events, staff users, sessions, access keys, banners, audit log.

create type role as enum (
  'admin', 'head_referee', 'referee', 'judge_advisor', 'judge', 'queuer', 'emcee', 'scorekeeper', 'display'
);
create type event_status as enum ('draft', 'active', 'archived');
create type banner_severity as enum ('info', 'success', 'warning', 'error');

create function set_updated_at() returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table events (
  id uuid primary key,
  code text not null unique check (code ~ '^[A-Z0-9-]{3,32}$'),
  name text not null check (length(name) between 1 and 200),
  season_id text not null,
  timezone text not null,
  starts_on date not null,
  ends_on date not null check (ends_on >= starts_on),
  status event_status not null default 'draft',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create unique index events_one_active on events (status) where status = 'active';
create trigger events_updated_at before update on events for each row execute function set_updated_at();

create table users (
  id uuid primary key,
  username text not null unique check (username ~ '^[a-z0-9_.-]{2,64}$'),
  display_name text not null,
  password_hash text not null,
  roles role[] not null check (cardinality(roles) > 0),
  disabled boolean not null default false,
  must_change_password boolean not null default false,
  -- Login tokens issued before this instant are rejected (password change, role change, disable).
  tokens_valid_after timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create trigger users_updated_at before update on users for each row execute function set_updated_at();

create table access_keys (
  id uuid primary key,
  event_id uuid not null references events (id) on delete cascade,
  key_hash bytea not null unique,
  prefix text not null,
  label text not null check (length(label) between 1 and 100),
  roles role[] not null check (cardinality(roles) > 0),
  expires_at timestamptz,
  revoked_at timestamptz,
  created_by uuid references users (id) on delete set null,
  last_used_at timestamptz,
  created_at timestamptz not null default now()
);
create index access_keys_event on access_keys (event_id);

-- Login tokens are signed JWTs, so they are not stored. A logged-out token's id is kept here until it would
-- have expired anyway; the server loads this list into memory at start.
create table revoked_tokens (
  jti uuid primary key,
  expires_at timestamptz not null
);

-- Server-generated secrets, such as the JWT signing key.
create table server_secrets (
  name text primary key,
  value bytea not null,
  created_at timestamptz not null default now()
);

create table banners (
  id uuid primary key,
  event_id uuid not null references events (id) on delete cascade,
  severity banner_severity not null,
  message text not null check (length(message) between 1 and 500),
  active boolean not null default true,
  created_by uuid references users (id) on delete set null,
  created_at timestamptz not null default now()
);
create index banners_event_active on banners (event_id) where active;

create table audit_log (
  id bigserial primary key,
  event_id uuid references events (id) on delete cascade,
  actor text not null,
  action text not null,
  entity_type text not null,
  entity_id uuid,
  data jsonb not null default '{}',
  at timestamptz not null default now()
);
create index audit_log_entity on audit_log (entity_type, entity_id);
