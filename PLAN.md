# TMS Rebuild Plan

Rust server, Dioxus web client, PostgreSQL. FIRST LEGO League (FLL) Challenge tournament management, rebuilt from the ground up.

Written 2026-10-29 by Claude Fable 5.1 from: a full read of `~/Projects/TMS-Legacy` and `~/Projects/TMS`, the official FLL BIOGLOW (2026-27) documents, and the current state of the Rust/Dioxus ecosystem. Intended to be handed to the next Claude session (Opus 5.5) and to Connor as the working spec.

---

## 0. How to use this document

- Part A (sections 1-4) is the "why": vision, what the two old systems taught us, the FLL facts the design must respect, and the architecture decisions with their reasoning.
- Part B (sections 5-16) is the "what": repository layout, data model, state machines, API, client, scoring crate, scheduling, judging and awards, offline sync, printables, security, testing, deployment.
- Part C (sections 17-19) is the "when": phased delivery with verification criteria per phase, open decisions for Connor, and references.

Working rules for the next session (these come from Connor's global `CLAUDE.md` and still apply):

- Connor writes the project code. The agent advises, explains, shows diffs and snippets. Writing files inside `TMS-new` needs an explicit request in that conversation plus a confirmation, every time.
- No git operations unless explicitly asked.
- Minimal code, no speculative abstractions, surgical changes. Connor must be able to explain every line to reviewers.
- When a section below says "decide", that is a decision for Connor. Defaults are given so work can proceed without blocking.

Naming used throughout: "TMS" means the new system. "Legacy" means `TMS-Legacy` (Flutter + echo_tree + FRB). "TMS-2" means `~/Projects/TMS` (Flutter + gRPC + sled).

---

# Part A: Why

## 1. Vision

A single Rust binary runs the event: it serves the API, the websocket feed and the static web client, and talks to PostgreSQL. Every device (tablet, laptop, phone, TV) opens the same web app. The app is role-aware, utilitarian, square, fast, and works for hours without a network for the two jobs that matter offline: robot-game scoresheets and judging rubrics.

Design principles, in priority order:

1. Standard over clever. REST for commands and queries, one websocket for push, JSON on the wire, PostgreSQL with real foreign keys. No replicated KV store, no FFI bridge, no gRPC-web shim, no protobuf codegen, no rule DSL.
2. One language, one source of truth. Domain types, season scoring and rubric definitions live in one shared crate compiled into both server and client. Server verification is free because it is the same code.
3. Server-authoritative state, client-owned forms. Match state, queue state, timers and rankings are owned by the server and pushed to clients. Scoresheets and rubrics are owned by the device until synced.
4. Explicit states with explicit transitions. Every lifecycle (match, slot queue, timer, scoresheet, rubric, judging session, access key) is an enum with a transition table, enforced server-side, rendered as named states with feedback in the UI. No "tap to cycle a symbol".
5. Integrated, not bolted on. Queueing is part of the match slot. Judging is a first-class flow with pods and timers. Scheduling is generated inside TMS. Awards are deliberated inside TMS.
6. Offline where it counts. Score entry and rubric entry never require the server. Everything else is a cached read-only view when offline.
7. Utilitarian UI. Square corners, clear borders, obvious buttons, semantic colours only for meaning, light and dark themes, dense dashboards that scale from phone to TV.

## 2. What the two previous systems taught us

### 2.1 Keep as inspiration

| From | Keep |
|---|---|
| Legacy | Role-centric design with a role-to-screen matrix and per-role guides. |
| Legacy | Server-authoritative match timer with countdown, end-game and end phases, with sounds. |
| Legacy | Load → Ready → Run → auto-complete match lifecycle; multiple matches on one timer. |
| Legacy | Referee tablet presence signal (SIG / STBY / RDY) visible to the head referee. |
| Legacy | Referee scoring UX: auto next team, live score, inline validation, counters for large ranges, mission images, GP with mandatory comment, No Show. |
| Legacy | Server recomputes and re-validates every submitted score using the same code as the client. |
| Legacy | Integrity catalogue (E000-E013, W000-W018) as a spec for data health checks. |
| Legacy | Auto backups with retention, purge, team data CSV export with column filters. |
| Legacy | Tournament-in-a-Box (FIRST Australia scheduler) CSV import, Version 1 block format. |
| Legacy | Season test harness: defaults valid, maximum score reachable, per-rule tests. |
| Legacy | Already has mission definitions for 2023-2026 including BIOGLOW Founders and Future editions in `tms_infra/src/infra/fll_infra/seasons/`. Port the data, not the engine. |
| TMS-2 | One binary serving API and web client; launcher with QR code to join; graceful shutdown. |
| TMS-2 | Snapshot-then-delta streaming with heartbeat; client reconnect with backoff. |
| TMS-2 | Role inheritance (head referee ⊇ referee, judge advisor ⊇ judge, admin ⊇ all). |
| TMS-2 | Strict clippy, rustfmt, pre-commit, typos. |
| TMS-2 | Result type plus confirm-dialog patterns for destructive actions. |

### 2.2 Drop, and why

| Thing | Why it goes |
|---|---|
| echo_tree (Legacy) | Home-grown replicated KV store: second registration and token, role passwords shipped to clients, prefix ACLs, whole-tree resync on checksum mismatch, silent write drops, no transactions. A normal DB plus change notifications replaces all of it. |
| flutter_rust_bridge (Legacy) | 28k generated lines so Dart could call Rust for scoring, JSON parsing and permission checks. With a Rust client the bridge disappears. |
| Scoring "blueprint" and rule DSL (Legacy) | String comparisons, single-word labels, rules separate from validation, seasons as giant literals. Replaced by typed Rust functions per mission. |
| In-memory match state (Legacy) | Lost on restart, re-broadcast every second, double-timer race on abort/restart. Timer state goes in the DB; broadcast on change only. |
| Client-side domain logic (Legacy) | Round computation, next-team selection, load gate, check-in semantics and GP-comment rule lived only in the Flutter client. All of it moves server-side or into the shared crate. |
| Queueing as a wall-clock-derived card status (Legacy) | Unused enum, tap-to-cycle check-in, no effect on anything else. Replaced by an explicit slot queue state machine. |
| sled as a relational store (TMS-2) | String-prefix keys, hand-rolled secondary indexes, stale indexes, O(n) deletes, uuid strings as foreign keys, no cross-table transactions. PostgreSQL. |
| gRPC + gRPC-Web on a second port (TMS-2) | CORS, HTTP/1 shim, XHR streaming, two codegen chains, protobuf messages doubling as DB rows (field renumbering silently broke stored data). REST + WS on one port. |
| TypeId-keyed `dyn Any` event bus (TMS-2) | Drops deletes and lagged messages. One typed `DomainEvent` enum. |
| Global `OnceCell` singletons (TMS-2) | Untestable. `AppState` passed through axum `State`. |
| Plaintext passwords, admin/admin, 7-day JWT with no revocation (both) | argon2id hashes, DB-backed revocable sessions, forced password change on first start. |
| Hand-rolled time types (both) | `chrono` / `time` with `timestamptz`; schedules carry real dates, not time-of-day. |
| Three transports plus two registrations (Legacy) | One REST base path, one websocket. |
| Periodic full-DB integrity scans every 5-10 s (both) | Deferred; when built it is event-driven per affected entity (section 14). |

## 3. FLL Challenge facts the design must respect

All from official BIOGLOW (2026-27) documents and the Tournament Manual (Rev. Sept 2024, still the published one). URLs in section 19.

### 3.1 Seasons

- 2026-27 BIOGLOW (FIRST CANOPY season). This is the last FIRST/LEGO Education season. Two editions exist: Founders Edition (classic SPIKE game, what TMS targets first) and Future Edition (new hardware, alliance game, separate rubrics, separate "Event Management System, coming soon"). Legacy already has mission data for both; TMS ships Founders first and leaves the season crate open for Future.
- 2025-26 UNEARTHED, 2024-25 SUBMERGED, 2023-24 MASTERPIECE. Port these from Legacy too so past-event data can be opened.

### 3.2 Robot game

| Fact | Value |
|---|---|
| Match length | 2:30 (150 s). Legacy default end-game trigger 30 s. |
| Official matches | 3 per team. Best single score counts. Ties by 2nd then 3rd best. Full tie: local decision. |
| Practice matches | Optional, before official rounds. Do not count. |
| Table pairing | One "tournament setup" = two tables; two teams play at once, one referee per table. M07 bonus in BIOGLOW depends on the opposing team. |
| Match cycle | 10 min typical: 2.5 setup, 2.5 match, 2.5 scoring, 2.5 reset. Six matches per hour per setup. |
| Scoresheet header | Team #, Match, Referee, Table, Team initials (sign-off). |
| Score agreement | Referee documents results with the team; agreement makes it official; head referee decides disputes. |
| Gracious Professionalism | Every match: Developing 2 / Accomplished 3 / Exceeds 4. Not part of robot score. Feeds Core Values score. No-show gets no GP. |
| No-show | No official re-match rule. Local decision. |
| Equipment Inspection | Pre-match, 20 points if all equipment fits one launch area under 305 mm. Part of the scoresheet. |
| Precision Tokens | Tokens left: 6 or 5 = 50 pts, 4 = 35, 3 = 25, 2 = 15, 1 = 10, 0 = 0 (official Excel scorer). |

BIOGLOW mission summary (max robot score 530 including EI and tokens): see Appendix A. Legacy `fll_2026.rs` already encodes these as questions; the new season crate re-expresses them as typed fields.

### 3.3 Judging

- One 30-minute session per team, 2-3 judges per pod, each pod sees at most 6 teams per day, 10-15 minutes after each team for rubrics.
- Session phases (official flowchart): Welcome 2 min, Innovation Project presentation 5, IP Q&A 5, Robot Design explanation 5, RD Q&A 5, Final share and feedback up to 8, then judges deliberate 10 and hand in rubrics before the next team.
- Rubrics: Innovation Project (10 rows) and Robot Design (10 rows), each row Beginning 1 / Developing 2 / Accomplished 3 / Exceeds 4; Exceeds requires a comment. Five rows per rubric are flagged as counting toward Core Values. Feedback page with "Great job" and "Think about" per area plus nominations for Breakthrough, Rising All-Star, Motivate. Exact rows in Appendix B.
- Core Values has no separate session. Core Values score = 10 CV-flagged rubric rows (max 40) + GP from robot game (3 matches × 2-4, max 12; scaled to a 3-match basis if more rounds).
- Head judge fills one rubric per team (Event Hub guidance). Judge Advisor oversees, never judges, leads allocation.

### 3.4 Awards and deliberation (Official Judging Spreadsheet logic)

- Area scores: IP = sum of 10 rows (max 40). RD = sum of 10 rows (max 40). CV = 10 flagged rows + GP (max 52). RG = best official match score.
- Area ranks: `RANK.EQ` descending (ties share rank). Missing area = team count + 1.
- Champion's score = IP rank + CV rank + RD rank + RG rank. Lowest wins. Ties share rank; no official tiebreak.
- Allocation order: verify data → sort by Champion's rank → Champion's awards → Advancement (count set by partner) → Robot Performance (all places) → CV 1st → IP 1st → RD 1st → 2nd places → 3rd → 4th → Coach/Mentor → Engineering Excellence → Breakthrough / Rising All-Star / Motivate → Peer → local awards.
- One judged award per team (Robot Performance, Coach/Mentor and Peer excepted). 30-50 % of teams should get an award. Ranks are never changed to suit an allocation.
- Required awards: Champion's, Core Values, Innovation Project, Robot Design, Robot Performance, Coach/Mentor. Optional: Engineering Excellence, Breakthrough, Rising All-Star, Motivate, Peer, local.

### 3.5 Scheduling

- Space guidance: 6 teams → 1 pod / 2 tables; 7-12 → 2 / 2; 13-18 → 3 / 2-4; 19-24 → 4 / 2-4; 25-30 → 5 / 4-6; 31-36 → 6 / 4-6.
- Judging cycle 40-45 min (30 + 10-15). Match cycle 10 min. No official minimum travel gap between a team's judging and its matches; organisers choose (10-15 min typical).
- Schedule elements: team check-in, coaches' meeting, opening ceremony, practice round, 3 ranking rounds, judging sessions, lunch, awards.
- FIRST Australia's scheduler is Tournament-in-a-Box (React, open source) exporting `scoring_import.csv` Version 1 blocks (teams, ranking matches, judging, practice matches). Legacy parses this. A rewrite called Cadence exists with no public docs.

### 3.6 Roles at an event

Admin (tournament director / event admin), Head Referee, Referee (one per table), Scorekeeper, Emcee (announcer), Field Manager, Robot Game Queuer, Judging Queuer, Judge Advisor, Judge (lead judge per pod), Pit Admin, AV. TMS roles are a pragmatic subset (section 6.2).

## 4. Architecture decisions

Each decision: what, why, what was rejected.

### ADR-1: Transport is REST + one WebSocket. No GraphQL, no gRPC.

- REST (JSON) for every command and query: login, CRUD, state transitions, sync, exports.
- One WebSocket at `/ws` for server push: snapshots, upserts, deletes, timer state, banners, clock sync.
- Why: both ends are Rust sharing one types crate, so end-to-end typing is already solved. GraphQL subscriptions are a custom WS protocol anyway; `async-graphql` would add a schema layer with no Rust-client codegen story. gRPC-web needs a proxy layer in browsers. Plain REST is curl-able and debuggable in devtools.
- Commands never go over the websocket. The client sends only `Hello`, `SetSubscriptions`, `TimeSync`, `Pong`.

### ADR-2: JSON on the wire, inside a versioned envelope, documented with generated JSON Schema.

- `serde_json` text frames for REST and WS. All messages carry `v: u16`. WS messages are externally tagged with `#[serde(tag = "type", rename_all = "snake_case")]`, so a frame reads `{"type":"upsert","topic":"slots","item":{...}}`.
- Why: payloads are tiny (36 teams, ~150 slots, one timer state). JSON is inspectable in devtools, usable by outsiders with no toolchain, and the PWA's cached WASM can lag the server by days, so self-describing encoding matters for schema evolution (`#[serde(default)]` on new fields).
- "Standard" here means: an outsider can use the API with curl and a browser, and can read a schema for every message. Every DTO and WS message derives `schemars::JsonSchema`; the docs build emits the schemas into the docs site next to the OpenAPI document (section 17.2). No protobuf and no codegen pipeline: that is what made TMS-2 painful. MessagePack is opaque to outsiders.
- If measurement ever shows a need for binary, the same serde types are served on `/ws?encoding=msgpack` via `rmp-serde` with `with_struct_map()` (field names preserved). No protocol change. Do not use postcard or bincode across a deploy boundary; bincode 3.0 is a tombstone crate.
- Timer ticks are not streamed. The server sends a `TimerState` on each phase change; clients compute remaining time from a synced clock. This removes the biggest message volume Legacy had.

### ADR-3: PostgreSQL via sqlx 0.9 with hand-written SQL and real constraints.

- Explicit SQL, compile-time checked with `.sqlx` offline metadata committed, migrations in `migrations/`.
- Why: Connor wants relationships everywhere and the ability to explain every query. sqlx gives that without an ORM DSL. sea-orm 2.0 and diesel were considered; both add a layer that hides the SQL.
- Realtime fan-out is an in-process `tokio::sync::broadcast<DomainEvent>` emitted after each committed transaction. Postgres `LISTEN/NOTIFY` is not used initially: there is one server process, and NOTIFY loses messages during reconnects and is capped at 8000 bytes. Add it later only if a second writer or process appears.
- Where the database runs is ADR-13: embedded by default, external by flag. The SQL is identical either way.

### ADR-4: Dioxus 0.7.x standalone web client, served as static files by axum.

- `dioxus = { version = "0.7", features = ["web", "router"] }`. Not fullstack: server functions would hide the REST protocol and couple the crates. The client talks to the server with `gloo-net` (fetch + websocket).
- Do not start on the 0.8 alphas: they rework `rsx!` internals and element traits. Revisit when 0.8.0 ships.
- Why Dioxus over Flutter: one language, shared crate, no bridge, no codegen, compile-time breakage when a field is renamed.
- Known costs to plan for: WASM release builds are slow (use `opt-level = "z"`, `lto = true`, `codegen-units = 1`, `panic = "abort"`, and `wasm-opt`); signal guards held across `.await` panic at runtime; thin component ecosystem.

### ADR-5: Web client first, over HTTP or HTTPS. Native client builds come later.

Decided 2026-10-29 by Connor: focus on the web client the server serves. Native client binaries come later.

- **Now:** every device uses the web client in a browser, over HTTP or HTTPS (`--tls-cert`/`--tls-key`).
- **Later (Phase 9):** Dioxus builds of the same client crate for Android, iOS and desktop, connecting with the same REST, WebSocket and JWT, as the old TMS did with Flutter.
- **What works offline in the browser.** A page that is already open keeps running when the network drops, because the app is in memory and storage is on the device. Scoresheets and rubrics are saved to IndexedDB through the `idb` crate and sync later (ADR-8). Neither of those needs HTTPS.
- **What does not.** Reloading or first-opening the page with no network needs a service worker, and browsers only allow service workers over HTTPS. That "installable, opens offline" mode is deferred. It becomes optional polish once an event uses HTTPS, or it is covered by the native clients.
- **Device gotchas still designed for:**
  - tablets suspend backgrounded tabs, so the client resyncs on `visibilitychange`
  - a page reload while offline loses the cached views but not saved scoresheets
  - set Auto-Lock to Never or use Guided Access on all-day devices

### ADR-6: Seasons are typed Rust code in a shared crate, not data.

- Each season is a module in `tms-seasons` implementing a `Season` trait: mission field definitions (for rendering), `score(&Answers) -> ScoreResult` (points plus validation issues), rubric definition, GP options.
- Answers are `BTreeMap<FieldId, Answer>` where `Answer` is `Bool | Count(u8) | Choice(u8)`. Scoring is ordinary Rust with typed accessors. Validation and scoring are one function, so prerequisites are written once.
- Why: Legacy's DSL did string comparisons and needed every prerequisite twice. Typed Rust is shorter, testable against the official Excel scorer, and compiles into both client and server.
- Stored scoresheets record `season_id` and `schema_version` so a device with an old build cannot be merged into the wrong event.

### ADR-7: Login with username and password, or with an event access key. Tokens are JWTs.

Wording rule (Connor, 2026-10-29): the UI and docs say "login", "log out", "users" and "access key". They never say "staff" or "volunteers", because events mix roles in many ways. Pages built around matches, teams and judging use their specific names.

- **Password login.** Users log in with username and password, hashed with argon2id.
- **Tokens.** The server issues an HS256 JWT holding the principal (user or key), roles, a must-change-password flag, `jti`, `iat_ms` and `exp`. It is sent as `Authorization: Bearer`. The signing secret is generated on first start and kept in `server_secrets`. JWT was chosen by Connor over database sessions on 2026-10-29.
- **Lifetimes.** A password login lasts 12 h. A key login lasts 24 h, capped at the key's own expiry. `POST /auth/refresh` issues a new token, and the client refreshes when less than 6 h remain.
- **Revocation stays instant without a lookup per request.** The server keeps a revocation list in memory, loaded at start and updated on every change:
  - logged-out `jti`s, persisted in `revoked_tokens` until their expiry
  - a per-user cutoff (`users.tokens_valid_after`) for password changes, role changes and disabling
  - revoked key ids

  Open WebSockets whose token gets revoked receive `auth.revoked` and are closed.
- **Rate limiting.** Failed logins are limited per client address: 10 per 5 minutes, then 429.
- Access keys are created by an admin per event, bound to a role, optionally to a table or pod, with a label, expiry and revocation. The key string carries a role prefix (`REF-`, `JDG-`, `HR-`, `JA-`, `QUE-`, `MC-`, `DSP-`) so an offline device can render the right UI before the server has ever verified it. The server stores a SHA-256 of the key (keys are 64+ bits of entropy).
- Offline login: the login page has an "Enter access key" path that works with no server. The client stores the key and the role from the prefix, marks the session "unverified", and allows offline scoresheet/rubric entry plus cached views. Every request later carries the key and the server enforces the real role. Section 13 has the full flow.

### ADR-8: Scoresheets and rubrics are client-owned documents with an outbox.

- The device creates the document with a UUIDv7 `id`, the event id and code, season id, schema version, the key or user, timestamps, and the team binding (team id if known, else typed team number, else unbound).
- The outbox syncs in batches to `POST /api/v1/sync/scoresheets` (and `/sync/rubrics`), idempotent by `id`. The server replies per item: accepted, duplicate, needs binding, rejected (wrong event, wrong season, invalid key, revoked key, schema mismatch).
- The device keeps a history page under Settings: list, filter by status, bind unbound sheets to teams, retry, clear synced.

### ADR-9: Timers are server-authoritative state, not streams.

- `TimerState { phase, started_at (server ms), duration_ms, endgame_ms, countdown_ms, match_ids }` persisted in `timers` and broadcast on change. A server task fires the automatic transitions (countdown → running → endgame → ended) and marks matches finished.
- Clients compute remaining time from `server_now = client_now + offset`, where offset comes from `TimeSync` round trips (median of the last five).
- Judging pods have the same mechanism with a phase list instead of a single duration.

### ADR-10: Printables are rendered server-side with Typst.

- `typst-as-lib` compiles `.typ` templates with JSON input (`sys.inputs`) and event logos to PDF. Templates: team schedule sheets, master match schedule, judging schedule, table and pod signs, prefilled paper scoresheets, award certificates, rankings sheet for the JA.
- Why: iPad Safari's print CSS is weak for multi-page branded output. Typst templates are quick to iterate and deterministic. Print CSS stays as a fallback for "print this screen".
- Cost: heavy dependency and compile time on the server crate. Put it behind a cargo feature so dev builds can skip it.

### ADR-11: Scheduling is generated in-process with block construction plus local search.

- Build judging blocks (pods × 40-45 min cycles) and match blocks (table pairs × cycle minutes) from the event's time windows and breaks, then assign teams with simulated annealing over a weighted penalty: hard constraints (no overlap, judging buffer, pod capacity, one judging session per team, N matches per team) and soft ones (spread between matches, table variety, opponent variety, no back-to-back, balanced gaps).
- Sizes are at most ~40 teams, so this solves in milliseconds. No LP/CP solver dependency. `huub` or `good_lp` only if provable feasibility is ever needed.
- Tournament-in-a-Box CSV import stays as an alternative input path.

### ADR-12: Multi-event schema, single active event per server.

- Every table carries `event_id`. The server has one active event at a time (setting), but past events stay in the DB for exports and for scoresheet rejection ("this sheet belongs to event X").
- Why: it costs one column per table now and avoids a painful migration later. Also what makes the "event code on every scoresheet" rule enforceable.

### ADR-13: A release is one zip folder: the `tms` program with PostgreSQL bundled inside, and a `web` folder.

Revised 2026-10-29 at Connor's request. Phase 0b first compiled the web client into the binary. That made a plain `cargo build` produce a program with no web page, tied every client change to a server rebuild, and hid the shipped client. A release is now laid out like Legacy's:

```
tms-<version>-<os>-<arch>/
  tms (tms.exe)     the server, PostgreSQL bundled inside
  web/              the web client (dx build output)
  README.txt
  data/             created on first start: postgres/, logs/, backups/, tms.toml
```

The program finds `web/` and `data/` next to its own executable, not in the current directory, so a double-click, a shortcut and a terminal elsewhere all behave the same. `--web-dir` and `--data-dir` override them. A debug build with no `web/` beside it uses the workspace's `dx build` output, and a missing client is explained on the page instead of a bare 404. PostgreSQL stays bundled inside the binary, because the server must start offline at a venue with nothing else to install.

The original record follows; where it says the client is inside the binary, the layout above replaces it.

- The release artifact is a single executable, `tms`, per OS. Running it needs no Docker, no database install and no separate web folder.
- PostgreSQL cannot be linked into a Rust program the way SQLite can. `postgresql_embedded` (0.22, features `bundled`, `tokio`, `tls-rustls-ring`) packs a pinned PostgreSQL 17 build into the executable at compile time. On first start it unpacks the binaries into the data folder, runs `initdb`, and starts `postgres` as a child process. `tms` owns that process: it binds to `127.0.0.1` on a free port, uses a random password stored in the data folder, stops it on shutdown, and clears a stale `postmaster.pid` after a hard kill.
- This lives in its own crate, `tms-db`: start or connect (embedded or `--database-url`), the connection pool, migrations, and backup/restore through the bundled `pg_dump`/`pg_restore`. The server and the launcher both use it. Backup and restore don't need the web stack, and the web stack doesn't need to know where the database came from.
- (Replaced, see above.) The web client's release build was compiled into the server with `rust-embed`. It is now the `web/` folder of the release, served with its pre-compressed `.br`/`.gz` variants; hashed files under `/assets` are cached for good and everything else is revalidated.
- External database: `--database-url postgres://...` (or `TMS_DATABASE_URL`) skips the embedded PostgreSQL entirely. This is for larger or managed setups: a shared Postgres, a cloud instance, or running the database on a separate machine.
- Costs, accepted:
  - the binary grows by the PostgreSQL archive (tens of MB; measure in Phase 0b)
  - each OS and CPU needs its own build, because the bundled archive is per target
  - the first start takes a few seconds to unpack
- Why not SQLite: Connor wants Postgres relationships and the option of an external server. The embedded route keeps one SQL dialect for both modes.
- Development needs no Docker either. Tests start their own embedded PostgreSQL. Builds check SQL against the committed `.sqlx/` data. A dev server run with `--db-port` gives database tools a fixed port.

### ADR-14: A native launcher supervises the server as a child process.

- Running `tms` with no arguments opens a small native window: the launcher. Running `tms --headless` (alias `--no-gui`) runs the server in the terminal with no window. Both are the same binary.
- The launcher never runs the server inside its own process. It starts `tms --headless --supervised --config <file>` as a child process and watches it. Reasons:
  - The server stays the main thread of its own process. A GUI cannot share that: on macOS the window toolkit must own the main thread.
  - A server crash or a failed start cannot take the window down. The launcher sees the exit code and the last log lines, and shows them in an error popup.
  - Headless and launcher runs execute exactly the same code with the same arguments. The launcher only writes the config file and builds the command line.
  - The launcher can stop the server, which lets it do the jobs that were always awkward from the web UI: restoring a backup, swapping the database, changing ports.
- GUI toolkit: `eframe`/`egui` (0.37). TMS-2 already proved it for this purpose. It is small, native, cross-platform, and needs no webview. Dioxus desktop was considered and rejected: it needs a system webview and would make the launcher as heavy as the app it launches.

---

# Part B: What

## 5. Repository layout

Cargo workspace at `TMS-new/`:

```
TMS-new/
  Cargo.toml                 workspace, shared [workspace.dependencies], release profile
  rust-toolchain.toml        stable, rustfmt, clippy
  rustfmt.toml               (copy TMS-2: 2-space, 120 cols)
  .cargo/config.toml         clippy pedantic + allows (copy TMS-2), wasm target notes
  crates/
    tms-core/                domain types, enums, state machines, DTOs, ranking, validation (no IO)
    tms-seasons/             Season trait + one module per season (bioglow, unearthed, submerged, masterpiece)
    tms-schedule/            schedule generator and conflict checker (pure functions over tms-core types)
    tms-db/                  database lifecycle: embedded PostgreSQL or external URL, pool, migrations, backup/restore (ADR-13)
    tms-server/              axum app as a library: REST, WS hub, sqlx repos, services, typst printables, embedded client
    tms-launcher/            the shipped binary `tms`: CLI parsing, config file, headless `serve`, egui launcher window (section 17.1)
    tms-client/              dioxus web app
    tms-ui/                  design system components (buttons, badges, tables, shell) used by tms-client
  migrations/                sqlx migrations (timestamped .sql)
  .sqlx/                     committed sqlx offline metadata
  assets/
    typst/                   .typ templates
    missions/<season>/       mission images (ported from Legacy)
    audio/                   start, end-game, end, stop, short-beep (ported)
  scripts/release.sh         builds the single `tms` program for this platform
  docs/                      mkdocs: architecture, roles guides, season authoring, ops
  scripts/                   dev helpers (db reset, sqlx prepare, build-client)
```

Crate dependency direction: `tms-core` ← `tms-seasons` ← `tms-schedule` ← `tms-server`; `tms-db` ← `tms-server`; `tms-launcher` depends on `tms-server` and `tms-db`; `tms-client` depends on `tms-core`, `tms-seasons`, `tms-ui`. `tms-core` and `tms-seasons` must compile for `wasm32-unknown-unknown` (no tokio, no sqlx; `chrono` with `wasmbind`, `uuid` with `js` feature).

Key dependencies (versions verified 2026-10-29):

| Crate | Version | Used for |
|---|---|---|
| axum | 0.8.9 | HTTP + WS (`ws` feature) |
| tower-http | 0.7.1 | `ServeDir` with SPA fallback, compression, trace |
| tokio | 1.54 | runtime, broadcast, timers |
| sqlx | 0.9 | Postgres, migrations, compile-time queries (`runtime-tokio`, `tls-rustls`, `postgres`, `uuid`, `chrono`, `json`) |
| serde / serde_json | 1 | all DTOs |
| uuid | 1 (`v7`, `serde`, `js`) | ids |
| chrono | 0.4 (`serde`) | times; `DateTime<Utc>` everywhere, event timezone for display |
| argon2 | 0.5 | password hashes |
| sha2 | 0.10 | access key hashes |
| rand | 0.9 | tokens, keys |
| utoipa + utoipa-axum | 6.0 / 0.3 | OpenAPI doc at `/api/docs` (optional but cheap) |
| typst-as-lib | 0.17 (typst 0.15) | printables (feature `print`) |
| csv | 1 | TiaB import, exports |
| dioxus | 0.7.10 (`web`, `router`) | client |
| gloo-net | 0.7 | fetch + websocket in WASM |
| idb | 0.6 | IndexedDB |
| web-sys / wasm-bindgen | 0.3.106 / 0.2.129 | storage persist, visibility, audio |
| testcontainers-modules | 0.15 (`postgres`) | server integration tests |

Tooling: `dx` CLI 0.7.10 for the client (`dx serve --package tms-client`, `dx build --release`), `sqlx-cli` 0.9, `cargo-watch` for the server, Tailwind v4 CLI (`@tailwindcss/cli`) if Tailwind is chosen (section 10.3).

## 6. Data model

### 6.1 Conventions

- Primary keys are `uuid` (v7 for time ordering) except join tables.
- Every event-scoped table has `event_id uuid not null references events(id) on delete cascade`.
- `created_at timestamptz not null default now()`, `updated_at` maintained by a trigger on tables that are edited.
- Enums are Postgres enums mirrored by `#[derive(sqlx::Type)]` enums in `tms-core` with `#[sqlx(type_name = "...", rename_all = "snake_case")]`.
- Natural keys get unique constraints scoped by event (`unique (event_id, number)`).
- Soft history is done with `supersedes_id` chains on scoresheets and rubrics, not with deletes.
- `audit_log` records every state transition and admin edit with actor and payload.

### 6.2 Enums (in `tms-core`, mirrored in SQL)

```rust
pub enum Role { Admin, HeadReferee, Referee, JudgeAdvisor, Judge, Queuer, Emcee, Scorekeeper, Display }
// inheritance: Admin ⊇ all; HeadReferee ⊇ Referee, Queuer; JudgeAdvisor ⊇ Judge; Display = read-only public topics

pub enum EventStatus { Draft, Active, Archived }
pub enum RoundKind { Practice, Ranking }
pub enum TableSide { A, B }

pub enum MatchState { Scheduled, Staged, Running, Finished, Scored, Cancelled }

pub enum SlotQueueState {
    NotCalled, Called, OnWay, Staged, AtTable, Ready, Running, Done, NoShow, Scratched
}

pub enum TimerPhase { Idle, Countdown, Running, Endgame, Ended, Aborted }

pub enum ScoresheetStatus { Submitted, Accepted, Rejected, Published, Superseded }
pub enum RubricStatus { Submitted, Accepted, Rejected, Superseded }

pub enum JudgingSlotState { Scheduled, InSession, Deliberating, Complete, NoShow }
pub enum JudgingQueueState { NotCalled, Called, OnWay, Waiting, InRoom, Done, NoShow }

pub enum AwardKind {
    Champions, CoreValues, InnovationProject, RobotDesign, RobotPerformance, CoachMentor,
    EngineeringExcellence, Breakthrough, RisingAllStar, Motivate, Peer, Local
}

pub enum BannerSeverity { Info, Success, Warning, Error }
pub enum Gp { Developing = 2, Accomplished = 3, Exceeds = 4 }
```

### 6.3 Tables

Event and people:

```sql
events (
  id uuid pk, code text unique,            -- short public code e.g. "BIOG-SYD-26", printed on devices and sheets
  name text, season_id text,                -- 'bioglow_founders'
  timezone text,                            -- 'Australia/Sydney'
  starts_on date, ends_on date,
  status event_status,
  settings jsonb                            -- EventSettings struct (section 6.5)
)
users (id uuid pk, username text unique, display_name text, password_hash text, roles role[] , disabled bool, must_change_password bool)
sessions (id uuid pk, token_hash bytea unique, user_id fk, device_label text, created_at, expires_at, last_seen_at, revoked_at)
access_keys (
  id uuid pk, event_id fk, key_hash bytea unique, prefix text, label text,
  roles role[], table_id uuid null fk, pod_id uuid null fk,
  expires_at timestamptz null, revoked_at timestamptz null, created_by uuid fk users, last_used_at
)
```

Teams and venue:

```sql
teams (id, event_id, number text, name text, affiliation text, pit text null, notes text,
       unique (event_id, number))
game_tables (id, event_id, name text, pair_no int, side table_side, sort_order int,
             unique (event_id, name), unique (event_id, pair_no, side))
pods (id, event_id, name text, room text null, sort_order int, unique (event_id, name))
schedule_blocks (id, event_id, kind text, name text, starts_at timestamptz, ends_at timestamptz)
   -- lunch, opening ceremony, awards, coaches meeting; used by the generator and the displays
```

Robot game:

```sql
rounds (id, event_id, kind round_kind, number int, name text, unique (event_id, kind, number))
game_matches (
  id, event_id, number int, round_id fk,
  scheduled_start timestamptz, scheduled_end timestamptz,
  state match_state, staged_at, started_at, finished_at,
  unique (event_id, number)
)
match_slots (
  id, match_id fk, table_id fk, team_id uuid null fk,
  queue_state slot_queue_state, queue_changed_at, queue_changed_by text,
  scoresheet_id uuid null fk,              -- the currently published sheet for this slot
  unique (match_id, table_id),
  unique (match_id, team_id) deferrable
)
slot_queue_events (id, slot_id fk, from_state, to_state, actor text, note text, at)
timers (
  id, event_id, kind text,                 -- 'match' | 'pod'
  pod_id uuid null fk,
  phase timer_phase, started_at timestamptz null,
  duration_ms int, endgame_ms int, countdown_ms int,
  phase_index int null,                    -- pods: which phase of the session plan
  match_ids uuid[] ,
  updated_at, unique (event_id, kind, pod_id)
)
scoresheets (
  id uuid pk,                              -- client generated v7
  event_id fk, event_code text, season_id text, schema_version int,
  team_id uuid null fk, team_number_text text null,
  round_id uuid null fk, match_id uuid null fk, table_id uuid null fk, slot_id uuid null fk,
  submitted_by_user uuid null, submitted_by_key uuid null, referee_name text,
  status scoresheet_status, supersedes_id uuid null fk scoresheets,
  no_show bool, score int, gp smallint null check (gp between 2 and 4),
  answers jsonb,                           -- BTreeMap<FieldId, Answer>
  team_agreed bool, team_initials text null,
  private_comment text, review_note text,
  created_at timestamptz,                  -- device time
  received_at timestamptz, reviewed_by uuid null, reviewed_at timestamptz null
)
create unique index one_published_per_team_round
  on scoresheets (team_id, round_id) where status = 'published';
```

Judging:

```sql
judging_sessions (id, event_id, number int, scheduled_start, scheduled_end, unique (event_id, number))
judging_slots (
  id, session_id fk, pod_id fk, team_id uuid null fk,
  state judging_slot_state, queue_state judging_queue_state, queue_changed_at,
  started_at, finished_at, rubric_id uuid null fk,
  unique (session_id, pod_id), unique (session_id, team_id)
)
rubrics (
  id uuid pk, event_id fk, event_code text, season_id text, schema_version int,
  team_id uuid null fk, team_number_text text null, pod_id uuid null fk, slot_id uuid null fk,
  submitted_by_user uuid null, submitted_by_key uuid null, judge_names text,
  status rubric_status, supersedes_id uuid null,
  feedback jsonb,                          -- { cv: {great, think}, ip: {...}, rd: {...} }
  nominations award_kind[],                -- Breakthrough, RisingAllStar, Motivate
  created_at, received_at, reviewed_by, reviewed_at
)
rubric_scores (rubric_id fk, criterion_id text, level smallint check (level between 1 and 4),
               exceeds_comment text null, primary key (rubric_id, criterion_id))
create unique index one_accepted_rubric_per_team on rubrics (team_id) where status = 'accepted';
```

Awards:

```sql
awards (id, event_id, kind award_kind, name text, places int, enabled bool, sort_order int)
award_assignments (id, award_id fk, team_id fk, place int, note text, unique (award_id, team_id))
advancements (event_id, team_id, rank int, primary key (event_id, team_id))
nominations (id, event_id, kind award_kind, team_id fk, nominated_by text, text text)  -- coach/mentor, peer
deliberation_overrides (event_id, team_id, area text, deliberated_rank int)             -- JA manual rank adjustments, recorded, never silently applied
```

Cross-cutting:

```sql
banners (id, event_id, severity banner_severity, message text, active bool, created_by, created_at, expires_at null)
audit_log (id bigserial, event_id, actor text, action text, entity_type text, entity_id uuid, data jsonb, at)
settings (key text pk, value jsonb)        -- active_event_id, server-level config
```

### 6.4 Derived data (views, computed in Rust, never stored)

- `team_round_scores`: per team per ranking round, the published sheet's score. SQL view for exports.
- Rankings: computed in `tms-core::ranking` from published ranking-round sheets: best, second, third; competition rank ("1, 1, 3") matching `RANK.EQ`. The server recomputes on every scoresheet publish and pushes a `rankings` topic snapshot.
- Judging area scores and Champion's score: `tms-core::deliberation` from accepted rubrics plus GP from published sheets. Pushed on the `deliberation` topic to JA/admin only.

### 6.5 EventSettings (jsonb, typed in `tms-core`)

```rust
pub struct EventSettings {
    pub match_duration_ms: u32,            // 150_000
    pub endgame_ms: u32,                   // 30_000
    pub countdown_ms: u32,                 // 5_000
    pub ranking_rounds: u8,                // 3
    pub practice_rounds: u8,               // 0 or 1
    pub scoresheet_review: ScoresheetReview, // AutoPublish | HeadRefereeReview
    pub gp_comment_required_unless_accomplished: bool,
    pub require_team_agreement: bool,      // sign-off checkbox on sheet
    pub judging_phases: Vec<JudgingPhase>, // name + minutes; default official flowchart
    pub judging_buffer_min: u16,           // 15
    pub judging_match_gap_min: u16,        // 15, used by generator and conflict check
    pub scoreboard: ScoreboardSettings,    // show per-round scores, hide until round published, page size, rotation seconds
    pub audio: AudioSettings,              // which displays play sounds by default
    pub logos: Vec<AssetRef>,              // for printables and displays
}
```

## 7. Domain state machines

All transitions are enforced in `tms-core` as pure functions `fn transition(state, action, ctx) -> Result<state, TransitionError>` and applied by the server inside a transaction. The client calls REST endpoints named after actions, never "set state to X".

### 7.1 Match

```
Scheduled --stage(HR)--> Staged --start(HR|Emcee)--> Running --timer end|end(HR)--> Finished --all slots scored or no-show--> Scored
Staged --unstage(HR)--> Scheduled
Running --abort(HR)--> Staged             (timer Aborted; slots back to Ready/AtTable)
any except Running --cancel(Admin|HR)--> Cancelled
Finished --reopen(HR)--> Finished         (allows a new sheet; previous sheet superseded)
```

Staging rules (server-side, replacing Legacy's client-only gate): a match can be staged only if no match is Running, and every table in it has no earlier Finished match with an unscored, non-no-show slot, unless `force` is passed by HR with a reason (audited). Multiple matches may be staged together if they share no tables; they run on the one match timer.

### 7.2 Slot queue (the integrated queueing)

```
NotCalled --call(Queuer)--> Called --on_way(Queuer)--> OnWay --staged(Queuer)--> Staged
   --at_table(Referee)--> AtTable --ready(Referee)--> Ready --(match start)--> Running --(match end)--> Done
Any pre-Running --no_show(Queuer|Referee|HR)--> NoShow
Any pre-Running --scratch(HR|Admin)--> Scratched     (team not playing this match; counts as no sheet)
NoShow --undo(HR)--> previous
Shortcuts: Referee may jump NotCalled/Called/OnWay -> AtTable directly (team just turned up).
```

Each transition is an audited `slot_queue_events` row and a WS `Upsert{slots}`. The UI shows the state as a named badge with a dropdown of the legal next actions for the caller's role; the server's response (or error) is shown as a toast. Queue views derive "Now calling" from state, not from wall clock, but display scheduled time and countdown as context.

Referee presence (Legacy's SIG/STBY/RDY) becomes the websocket connection itself: the hub knows which key (bound to a table) is connected, and the head referee view shows per-table connected / disconnected plus the last Ready signal. No 5-second polling.

### 7.3 Match timer

```
Idle --start_with_countdown--> Countdown --(countdown_ms)--> Running --(duration-endgame)--> Endgame --(endgame)--> Ended --(auto 2 s)--> Idle
Idle --start--> Running
Countdown|Running|Endgame --abort(HR)--> Aborted --(auto 2 s)--> Idle
```

Start requires all staged slots to be Ready, NoShow or Scratched, unless `force`. The server task is a single `tokio::task` per timer holding a cancellation token; abort cancels it, so Legacy's double-timer race cannot occur. On `Ended`, matches go Finished and slots Done.

### 7.4 Scoresheet

```
(device) Draft --submit--> Pending (outbox) --sync accepted--> Submitted
Submitted --auto (AutoPublish and valid)--> Published
Submitted --accept(HR)--> Published
Submitted --reject(HR, note)--> Rejected        (referee station shows the note; a new sheet is expected)
Published --supersede (new sheet for same team+round published)--> Superseded
Published --unpublish(HR)--> Submitted
```

Server validation on sync: season and schema match the event; key/user valid and role permits; if `team_id` present it belongs to the event; if `slot_id` present it belongs to that team; recompute score with `tms-seasons` and reject if the recomputed score differs or validation issues exist (unless `no_show`); if `round_id` is missing but `slot_id` is present, derive it; if the team and round already have a Published sheet, mark the new one Submitted and flag "duplicate round" for HR even in AutoPublish mode.

### 7.5 Judging session slot and pod timer

```
Slot: Scheduled --start(Judge)--> InSession --phases...--> Deliberating --rubric accepted or finish(Judge)--> Complete
      Scheduled --no_show(Judge|JA)--> NoShow
Pod timer: Idle --start--> phase[0] --next|auto--> phase[1] ... --> Idle (phase_index tracks position; judges can skip or extend a phase)
```

Judging queue state mirrors the robot game one with `Waiting` (outside room) and `InRoom`.

### 7.6 Rubric

Same as scoresheet minus auto-publish: `Submitted --accept(JA)--> Accepted`, `reject(JA)`, `supersede`. JA may also set `Accepted` directly when the head judge submits and the event setting `rubric_review = Auto`.

### 7.7 Access key

`Active --revoke--> Revoked`, `Active --(expires_at)--> Expired`. Keys are shown once at creation (plus a QR code); afterwards only the prefix and label are visible.

## 8. Server (`tms-server`)

### 8.1 Structure

```
src/
  (no main.rs: the `tms-launcher` crate owns the program, its flags and start-up)
  config.rs          bind addr, database_url, tls cert/key, static dir, log level
  app.rs             build axum Router, AppState { pool, events: broadcast::Sender<DomainEvent>, hub, clock }
  auth/              extractors: Session (user), KeyAuth (access key), RequireRole<R>
  http/              one module per resource: events, users, keys, teams, tables, pods, rounds, matches, slots, timers, scoresheets, judging, rubrics, awards, schedule, sync, exports, printables, banners
  ws/                hub.rs (connections, subscriptions, fan-out), protocol.rs (uses tms-core::ws types), snapshots.rs
  repo/              sqlx query functions grouped by table; no business logic
  services/          match_service, timer_service, queue_service, scoring_service, judging_service, deliberation_service, schedule_service, sync_service
  events.rs          DomainEvent enum + publish helper (after commit only)
  print/             typst templates loader (feature "print")
  import/            tiab_csv.rs (Tournament-in-a-Box Version 1)
```

Pattern for every command: handler extracts auth and DTO → service begins a transaction → repo reads → `tms-core` transition/validation → repo writes → audit row → commit → publish `DomainEvent`s → return the updated entity. Errors are a single `ApiError` enum mapped to `{ "code": "slot.invalid_transition", "message": "...", "details": {...} }` with 400/401/403/404/409/422.

### 8.2 REST API (`/api/v1`)

Auth:

```
POST /auth/login                 {username, password} -> {token, user, roles, expires_at}
POST /auth/key                   {key} -> {token?, roles, event, bindings}   (verifies a key; returns a session bound to the key)
POST /auth/logout
GET  /auth/me
```

Event and setup (Admin):

```
GET/POST   /events ; GET/PATCH /events/{id} ; POST /events/{id}/activate ; POST /events/{id}/archive ; POST /events/{id}/purge
GET/PATCH  /events/{id}/settings
CRUD       /events/{id}/teams, /tables, /pods, /rounds, /schedule-blocks, /awards, /banners, /keys (POST returns the plaintext key once), /users
POST       /events/{id}/import/tiab        multipart csv; dry-run flag returns the parsed plan and conflicts; commit replaces schedule atomically (refused if any published sheet exists unless force)
GET        /events/{id}/audit?entity=...&since=...
```

Robot game:

```
GET  /events/{id}/matches?round=...&table=...&state=...
POST /matches/{id}/stage | unstage | start | start-countdown | end | abort | cancel | reopen   (HR; emcee may start/start-countdown)
PATCH /matches/{id}                    scheduled times, round (HR/Admin; conflict check runs)
POST /matches                          insert ad-hoc match (HR/Admin)
POST /slots/{id}/queue                 {action: Call|OnWay|Staged|AtTable|Ready|NoShow|Scratch|Undo, note?}
PATCH /slots/{id}                      {team_id}  reassign team (HR/Admin; conflict check)
POST /matches/{id}/swap-slots          {slot_a, slot_b} (HR)
GET  /events/{id}/timer ; POST /events/{id}/timer/{start|start-countdown|abort|end}
GET  /events/{id}/rankings
GET  /tables/{id}/station              referee station snapshot: current slot, next N slots, pending sheet statuses
```

Scoresheets:

```
POST /sync/scoresheets                 batch upsert, idempotent by id; per-item results (section 13)
GET  /events/{id}/scoresheets?status=&team=&round=&table=
GET  /scoresheets/{id}
POST /scoresheets/{id}/accept | reject | unpublish   (HR)
PATCH /scoresheets/{id}                HR/JA edit answers (creates a superseding sheet, keeps the original)
POST /scoresheets/{id}/bind            {team_id, round_id?, slot_id?}
```

Judging:

```
GET  /events/{id}/judging/sessions ; CRUD slots
POST /judging/slots/{id}/queue         same action shape as match slots
POST /judging/slots/{id}/start | finish | no-show
GET  /pods/{id}/timer ; POST /pods/{id}/timer/{start|next|previous|extend|stop}
GET  /pods/{id}/station                judge station snapshot
POST /sync/rubrics ; GET /events/{id}/rubrics ; POST /rubrics/{id}/accept | reject ; PATCH /rubrics/{id}
GET  /events/{id}/deliberation         area scores, ranks, champion's, nominations (JA/Admin)
POST /events/{id}/awards/{award_id}/assign   {team_id, place}
POST /events/{id}/advancements         [{team_id, rank}]
POST /events/{id}/deliberation/finalize   locks rubrics and awards
```

Schedule:

```
POST /events/{id}/schedule/generate    GenerateRequest -> proposed schedule + conflicts (not persisted)
POST /events/{id}/schedule/commit      apply a proposal atomically
POST /events/{id}/schedule/check       run conflict checks on current data -> issues
POST /events/{id}/schedule/reschedule-team   {team_id, ...} -> candidate moves with their conflicts
```

Exports and printables:

```
GET  /events/{id}/export/{rankings|scores|rubrics|core-values|ojs-robot-game}.csv
GET  /events/{id}/print/{team-schedules|match-schedule|judging-schedule|table-signs|pod-signs|scoresheets|certificates|rankings}.pdf?params
```

Public (role Display or no auth, configurable): `GET /public/{id}/rankings`, `/schedule`, `/timer`.

OpenAPI via `utoipa` served at `/api/docs` is cheap once the DTOs derive `ToSchema`; optional.

### 8.3 WebSocket protocol (`/ws`)

Types live in `tms-core::ws` so both ends share them.

```rust
// As built in Phase 0 (crates/tms-core/src/ws.rs). Frames are tagged JSON: {"type":"hello",...}.
pub enum ClientMessage {
    // Only a session token. An access key is exchanged for a token at POST /auth/key first.
    Hello { v: u16, token: Option<String>, client_build: String },
    SetSubscriptions { topics: Vec<Topic> },   // the complete desired set, replaces the previous one
    TimeSync { client_ms: i64 },
    Pong,
}

pub enum ServerMessage {
    Welcome { v: u16, server_ms: i64, roles: Vec<Role> },   // the event arrives through the `event` topic
    Snapshot { topic: Topic, items: Vec<TopicItem> },
    Upsert { topic: Topic, item: TopicItem },
    Delete { topic: Topic, id: Uuid },
    TimeSync { client_ms: i64, server_ms: i64 },
    Error { code: String, message: String },
    Ping,
}
// Timers, rankings and presence are planned as topics with TopicItem variants (Timer, RankingRow, PresenceRow),
// not as separate message types, so every live datum follows the same snapshot-then-delta rule.
// Banners are already a topic: a snapshot of active banners, then upsert/delete.

pub enum Topic {
    Event, Teams, Team(TeamId), Tables, Pods, Rounds, Blocks,
    Matches, Match(MatchId), Slots { table: Option<TableId> },
    Timers, Timer { pod: Option<PodId> }, Rankings,
    Scoresheets { table: Option<TableId> },
    JudgingSessions, JudgingSlots { pod: Option<PodId> }, Rubrics { pod: Option<PodId> },
    Deliberation, Banners, Presence,
}
```

Topics serialise as plain strings so they are easy to document and to type by hand: `teams`, `team/0192f...`, `slots`, `slots?table=0192f...`, `timer?pod=...`. `Topic` implements `Display` and `FromStr`; the server rejects unknown strings with an `Error`.

Rules:

- `Hello` must arrive within 5 s. The hub resolves roles and filters topics: `Scoresheets`, `Rubrics`, `Deliberation`, `Presence` need the matching role; everything else is readable by any authenticated or Display connection. Unauthenticated connections get the public topics only. A topic the role may not read is dropped from the set and reported once with an `Error`, not a disconnect.
- Subscriptions are declarative. `SetSubscriptions` carries the complete desired set. The server dedups it, diffs it against the connection's current set, sends a `Snapshot` for each added topic (from the DB, inside one read transaction so the set is consistent), and stops forwarding removed topics. Duplicates and overlaps (`teams` plus `team/11`) are harmless: the client store merges by id. There is no incremental subscribe or unsubscribe message, so a missed message can never leave a subscription hanging; the next `SetSubscriptions` or reconnect restores truth.
- Fan-out: each `DomainEvent` is tagged with the topics it belongs to at publish time (a scoped event such as a slot change belongs to `slots`, `slots?table=X` and `match/Y`). Each connection task holds one `broadcast::Receiver<DomainEvent>`, does a set intersection with its subscriptions, and only then serialises and sends. Nothing is sent that the client did not ask for. On `RecvError::Lagged` the hub resends `Snapshot`s for every subscribed topic instead of dropping the client.
- Heartbeat: `Ping` every 10 s; client answers `Pong`; two missed pongs close the socket.
- Clock sync: the client sends `TimeSync` on connect and every 30 s; offset = `server_ms - (client_ms + rtt/2)`; keep the median of the last five.
- Reconnect is the client's job: exponential backoff 1 s to 16 s, `Hello` again, `SetSubscriptions` with the current set, snapshots replace local caches.

Client-side subscription management (`net/realtime.rs` plus a `use_subscription` hook):

- A registry `HashMap<Topic, usize>` of reference counts lives in the realtime service. `use_subscription(topic)` increments on first render of the component and decrements in `use_drop`, which Dioxus runs when the component unmounts. Scoped hooks such as `use_subscription(Topic::Slots { table: Some(my_table) })` are what station pages and displays use; admin and HR pages use the unscoped topics.
- Any change to the registry schedules a debounced (about 50 ms) send of `SetSubscriptions` with the set of topics whose count is above zero. The counts exist only to compute the set; the wire message is always the full set. A leaked count therefore costs at most one extra topic until the next change, never a stale server subscription.
- A route's layout component may also declare the topics every page under it needs, so navigation between pages that share topics does not cause an unsubscribe and resubscribe cycle; the debounce covers the rest.
- Snapshots and deltas are written into the topic stores keyed by id. When a topic's count drops to zero its store is kept as a cache (and persisted to IndexedDB for offline reads) but is marked stale; the next snapshot replaces it.

### 8.4 Domain events

```rust
pub enum DomainEvent {
    EventUpdated(EventSummary),
    TeamUpserted(Team), TeamDeleted(Uuid),
    TableUpserted(..), PodUpserted(..), RoundUpserted(..), BlockUpserted(..),
    MatchUpserted(GameMatch), MatchDeleted(Uuid),
    SlotUpserted(MatchSlot),
    TimerChanged(TimerState),
    ScoresheetUpserted(Scoresheet),
    RankingsChanged(Vec<RankingRow>),
    JudgingSessionUpserted(..), JudgingSlotUpserted(..), RubricUpserted(..),
    DeliberationChanged(DeliberationSnapshot),
    BannerChanged(Option<Banner>),
    PresenceChanged(Vec<PresenceRow>),
    ScheduleReplaced,       // clients resnapshot matches, slots, sessions
}
```

Published only after commit. Services return the list of events to publish; the handler publishes them.

## 9. Shared crate (`tms-core`)

- `ids`: newtype wrappers (`TeamId`, `MatchId`, ...) over `Uuid`.
- `model`: entity structs matching the tables, `serde` + `sqlx::FromRow` (sqlx behind a `server` feature so the client build does not pull it in).
- `dto`: request/response bodies, `ApiError`, pagination.
- `state`: transition functions and `TransitionError` for every lifecycle in section 7.
- `ranking`: `rank(sheets: &[PublishedScore]) -> Vec<RankingRow>` with best/second/third tiebreak and competition ranks.
- `deliberation`: area scores, area ranks, GP normalisation (3 scores sum; 4 × 0.75; 5 × 0.6), Champion's score and rank, one-judged-award rule, eligibility helpers.
- `ws`: protocol enums.
- `time`: `EventClock` (server offset), helpers for event timezone formatting.
- `settings`: `EventSettings` with defaults.
- `validation`: conflict check types (`Issue { code, severity, refs, message }`) and the hard-constraint checks used by both the generator and the manual editor.

No IO, no async, compiles to WASM. 100 % unit-testable.

## 10. Client (`tms-client` + `tms-ui`)

### 10.1 Application structure

```
tms-client/src/
  main.rs            launch, router, providers
  app.rs             AppShell: TopBar, Banner, SideNav, Outlet
  routes.rs          Route enum (dioxus-router), role guards
  net/
    api.rs           typed REST client (gloo-net), bearer injection, ApiError mapping
    realtime.rs      websocket task: connect, hello, ref-counted subscription registry + debounced SetSubscriptions, dispatch into stores, reconnect, time sync
    subscription.rs  use_subscription(topic) hook (increment on mount, decrement in use_drop)
    connectivity.rs  online/offline + server reachability signals, visibilitychange hook
  store/
    session.rs       SessionState { mode: Online(user|key) | OfflineUnverified(key) | Anonymous, roles, bindings }
    live.rs          one Signal per topic (teams, tables, matches, slots, timers, rankings, ...), indexed maps via use_memo
    local.rs         IndexedDB access: outbox (scoresheets, rubrics), cache (last snapshots), prefs
    sync.rs          outbox worker: batch, retry with backoff, per-item results
  pages/             one folder per screen (section 10.5)
  components/        app-specific composites (scoresheet form, rubric form, timer display, queue dropdown, match card, ...)
tms-ui/src/          design system primitives (section 10.3)
```

State model: `use_context_provider` at the root for `Session`, `Live`, `Local`, `Connectivity`. Topic caches are `Signal<Vec<T>>` plus `use_memo` indexes (`HashMap<Id, T>`), which is enough at these sizes; move to `#[derive(Store)]` only if a list re-render ever measures slow. Never hold a `.read()` guard across an `.await`.

Dioxus setup choices: `dioxus = { features = ["web", "router"] }`, `dx serve --package tms-client` with a proxy to the server for `/api` and `/ws` (configure `Dioxus.toml` `[web.proxy]`), release profile from the Dioxus optimising guide, `wasm-opt` on.

### 10.2 Routes and role matrix

| Route | Roles | Purpose |
|---|---|---|
| `/login` | all | Login: password or access key, with offline key entry |
| `/` | all | role-filtered dashboard tiles |
| `/display/scoreboard` | Display+ | TV scoreboard, fullscreen, rotation |
| `/display/timer` | Display+ | big timer with staged match and teams, optional table filter |
| `/display/queue` | Display+ | pit display: now calling, up next, queue states |
| `/display/schedule` | Display+ | match and judging schedule boards |
| `/display/awards` | Display+ | ceremony view (reveals one award at a time) |
| `/admin/event` | Admin | event, settings, season, logos, status |
| `/admin/teams`, `/admin/tables`, `/admin/pods`, `/admin/rounds`, `/admin/blocks` | Admin | CRUD |
| `/admin/users`, `/admin/keys` | Admin | user accounts, access keys with QR |
| `/admin/schedule` | Admin | generate, import TiaB, review proposal, commit, edit |
| `/admin/awards` | Admin | configure awards and places |
| `/admin/backups`, `/admin/audit` | Admin | ops |
| `/hr/control` | HeadReferee | match control: stage, timer, tables, presence, overrides |
| `/hr/matches` | HeadReferee | match list, edit, reschedule, swap, cancel |
| `/hr/scoresheets` | HeadReferee | review queue: submitted, rejected, duplicates; accept/reject/edit |
| `/referee` | Referee | referee station (section 10.5.3) |
| `/referee/scoresheet/{slot?}` | Referee | the scoresheet form |
| `/queue` | Queuer | queue board with action dropdowns, per-team search |
| `/emcee` | Emcee | announcer: staged match, teams, start buttons, rankings crib |
| `/ja/dashboard` | JudgeAdvisor | pods grid with timers, phase, current/next team, rubric status |
| `/ja/sessions` | JudgeAdvisor | session list, edit, reschedule |
| `/ja/rubrics` | JudgeAdvisor | review queue |
| `/ja/scores` | JudgeAdvisor | robot game scores and GP per team, exports |
| `/ja/deliberation` | JudgeAdvisor | ranks, award allocation workflow, advancement, finalize |
| `/judge` | Judge | judge station (section 10.5.6) |
| `/judge/rubric/{slot?}` | Judge | rubric form |
| `/settings` | all | device: theme, audio, bound table/pod, local documents history, sync, storage, about |
| `/print` | Admin, HR, JA | printables launcher |

### 10.3 Design system (`tms-ui`)

Decide: Tailwind v4 utilities over CSS variables (recommended, widely understood, Dioxus docs cover it) or hand-written CSS with Dioxus 0.7.3 scoped CSS. Either way the tokens are CSS custom properties in one file so themes are one block each.

Tokens:

- Radius: 2 px everywhere (`--radius: 2px`). Borders 1 px solid, visible in both themes.
- Spacing: 4 px grid. Density default is compact (dashboards); forms get comfortable spacing.
- Type: a neutral sans (Inter or IBM Plex Sans, self-hosted), `font-variant-numeric: tabular-nums` on every number, a monospaced display face for timers (keep Legacy's LCD font optional, default to a clean mono).
- Colour roles: `bg`, `surface`, `surface-raised`, `border`, `text`, `text-muted`, `primary`, `on-primary`, `success`, `warning`, `danger`, `info`, each with `-bg` and `-fg` variants for badges. Light: white surfaces, near-black text, teal primary (keep `#009485` from TMS-2 if wanted). Dark: `#15171c` background, `#1e2129` surfaces, light text. Semantic colours are used only for meaning: danger for destructive buttons and error states, warning for attention, success for confirmed/synced, info for neutral notices.
- Status mapping (one table in `tms-ui/src/status.rs`): every enum variant in section 6.2 maps to a label, a colour role and an icon. The same badge appears everywhere that state is shown.

Primitives: `Button { variant: Primary|Secondary|Ghost|Danger|Warning|Success, size, loading, icon }`, `IconButton`, `Badge`, `StatusBadge<E>`, `Card` (flat, bordered, optional header strip), `Panel`, `DataTable` (dense, sticky header, row actions), `Select`, `ActionDropdown` (list of legal actions, each shows a confirmation when destructive), `TextField`, `NumberStepper`, `Segmented` (for Yes/No and small choices), `Toggle`, `Tabs`, `Modal`, `Drawer`, `Toast` host, `Banner`, `KpiTile`, `TimerDisplay`, `EmptyState`, `Skeleton`, `QrCode`, `Kbd`.

Layout: `AppShell` = `TopBar` + `BannerSlot` + `SideNav` (collapsible, icons + labels, role-filtered) + content. Displays use `DisplayShell` (no nav, optional fullscreen toggle, large type).

Responsiveness: container queries for cards; phone (one column, nav as bottom sheet), iPad portrait and landscape (station layouts split 1/3 info and 2/3 form), desktop, TV (`/display/*` at 1080p and 4K with `clamp()` sizing).

### 10.4 TopBar and banner

TopBar content, left to right: event name and code; event clock (synced server time, event timezone); connection pill (Online / Reconnecting / Offline, with last sync time); sync pill (N pending documents, click → Settings history); binding pill (Table 3 / Pod B / none); role; theme toggle; user menu (logout, settings).

BannerSlot shows exactly one banner by priority: Error (server unreachable while an action is pending, sync rejections, storage not persistent) → Warning (offline-unverified session, service worker update ready, timer running while viewing a non-timer page) → Info (admin broadcast banner from `banners`) → Success (short-lived, e.g. "3 scoresheets synced"). Banners have a dismiss where safe and an action button where useful. The admin can push an event-wide banner from `/admin/event`.

### 10.5 Screen specifications

#### 10.5.1 Login

- Username/password form (online only; disabled with a hint when the server is unreachable).
- "Access key" tab: text field, QR scan hint (manual entry is fine; a camera scan is optional later). If online, verifies and returns bindings. If offline, parses the prefix, stores the key, shows a warning banner "Unverified offline session. Scoresheets will sync when a connection is available." and enters the role's station.
- Remembers the last key per device so a reopened PWA lands directly on the station.

#### 10.5.2 Head referee control (`/hr/control`)

Three columns on desktop, stacked on iPad.

- Left: match list grouped by round with state badges, scheduled time, "time until", tables and teams, staged highlight; filters; search.
- Centre: timer panel (big time, phase, staged matches with per-table team and slot state, start / start with countdown / end / abort; start disabled until all slots Ready or NoShow or Scratched, with a `force` toggle that asks for a reason).
- Right: tables grid: each table shows presence (connected key label), current slot state, last sheet status; click opens that table's station read-only.
- Bottom strip: pending scoresheet reviews count (link), duplicate-round flags, unscored finished slots.

#### 10.5.3 Referee station (`/referee`)

The replacement for Legacy's all-in-one auto-switching header.

- Header card: table name (from key binding or device setting), referee name field (persisted on device), connection and sync pills.
- "Now" card: the slot on this table in the Staged or Running match (if any): team number, name, affiliation, round and match number, queue state badge with action buttons `Team at table`, `Ready`, `No show`. If nothing is staged: "No match staged" with the next scheduled slot.
- "Up next" list: the next 5 slots on this table with scheduled time, team, queue state, countdown. Tap a row to see the team's previous scores on this table (read-only).
- Buttons: `Add scoresheet` (prefilled with the Now slot; if none, asks which upcoming slot or "unscheduled"), `Add unscheduled scoresheet` (choose team or type number; no slot binding).
- "Recent sheets" list: this device's sheets for today with status badges (Pending, Submitted, Published, Rejected with note, Needs binding). Tap → details, retry, open.
- Everything on this page renders from cached topic snapshots when offline. Actions that need the server are disabled with a tooltip, except `Add scoresheet`.

#### 10.5.4 Scoresheet form

- Sticky header: team, round, match, table, running score, validation count, `No show` toggle.
- Body: Equipment Inspection, then missions M01-M15 as cards with the mission image, each field rendered by type: Bool as a Yes/No segmented control, Count as a stepper with +/- and direct tap on a number row, Choice as segmented buttons. Dependent fields (bonuses) are disabled until their prerequisite is met, which is driven by the season's field definitions, not by UI code.
- Precision tokens as a 0-6 stepper. GP as three large buttons (2 / 3 / 4) with comment required when not 3 if the setting says so.
- Footer: private comment, `Team agreed` checkbox plus optional initials, `Clear`, `Submit`. Submit writes the document to IndexedDB and queues it, then returns to the station with a success toast. If online, the outbox sends immediately and the status flips to Submitted/Published within a second.
- Inline validation messages come from `tms-seasons` and block submit (unless No show).

#### 10.5.5 Queue board (`/queue`)

- Columns per round or a single time-ordered list, filter by table pair. Each row: match number, time, countdown, table, team, state badge, `ActionDropdown` with the legal queuer actions, plus a note field for `No show`.
- Top strip: "Now calling" (slots in Called/OnWay for matches starting within the next N minutes, N configurable), judging conflicts (teams whose judging slot is within the gap), and a team search (shows that team's full day).
- Works offline for reading; actions are disabled offline (no outbox for queue actions; they are time-sensitive and the server owns the state).

#### 10.5.6 Judge station (`/judge`) and rubric form

- Header: pod name, judge names field, pod timer with current phase name and remaining time; buttons `Start session`, `Next phase`, `Extend 1 min`, `Stop`.
- "Now" card: team in the current session slot with queue state and `Team in room` / `No show`.
- "Up next" list for this pod.
- `Add rubric` (prefilled) and `Add unscheduled rubric`.
- Rubric form: two pages (Innovation Project, Robot Design), each 10 rows; a row is the criterion label plus four selectable level cells showing the official descriptor text; CV-flagged rows carry a small marker; selecting Exceeds reveals a required comment field. A third page holds feedback ("Great job" / "Think about" per area) and nomination checkboxes for the optional awards the event enables. Footer: `Submit` (to outbox) and `Save draft`.
- Recent rubrics list with statuses, same as the referee station.

#### 10.5.7 Judge advisor dashboard and deliberation

- Dashboard: a tile per pod (timer, phase, current team, next team, judge key presence, rubric status for the last team); session progress bar; rubric review queue count; robot game ranking snapshot (JA sees scores, never shows teams).
- Scores page: table of teams with per-round robot scores, best, RG rank, GP per match, IP/RD/CV totals; filters; CSV and OJS-compatible exports.
- Deliberation: the OJS "Results and Rankings" sheet as a live table (area scores, area ranks, Champion's score and rank, nominations), followed by the allocation workflow in the official order as steps. Each step lists eligible teams in rank order with ineligibility reasons (already holds a judged award, nominated or not), and assigns place by button. A "deliberated rank" override per area is recorded with a note, never hidden. Advancement count field. `Finalize` locks the event's rubrics and awards and enables the ceremony display and certificate printing.

#### 10.5.8 Displays

- Scoreboard: rank, team number, name, best, per-round scores (or hidden until the round is published), auto-paging every N seconds for long lists, banner strip, event logo. Optional side panel: next matches.
- Timer: timer, phase colour (running neutral, end-game warning, ended danger), staged matches with table and team; optional filter to a table pair; sounds if enabled on this device.
- Queue display: now calling, up next (next 30-45 min), with state badges large enough to read from a pit.
- Schedule: match schedule and judging schedule boards, rotating.
- Awards: reveals one award at a time under emcee control (next/previous), confetti-free.

#### 10.5.9 Settings (device)

Theme, audio on/off, bound table or pod (if the key did not bind one), referee or judge names, local documents history with filters and actions (open, bind team, retry, delete draft, clear synced), storage status (persisted or not, usage), connection info (server URL, last sync, client build vs server version), "check for update" (service worker), sign out (warns if unsent documents exist).

### 10.6 PWA

- `client-public/index.html` registers `sw.js` and links `manifest.json` (standalone display, icons, theme colours for both schemes).
- `sw.js`: precache list generated at build time from the `dx build` output directory (a small script in `scripts/` writes `precache.json`), network-first for `/api`, cache-first for the shell and assets, `skipWaiting` on message, `clients.claim`.
- Update flow: on activation the client shows the "Update available, reload" banner; it never reloads on its own during a running timer or an open form.
- First run: request `navigator.storage.persist()`, show storage status in Settings.

## 11. Season crate (`tms-seasons`)

```rust
pub trait Season {
    const ID: &'static str;            // "bioglow_founders"
    const NAME: &'static str;          // "BIOGLOW (Founders Edition)"
    const SCHEMA_VERSION: u16;         // bump when fields change
    fn missions() -> &'static [MissionDef];
    fn score(answers: &Answers) -> ScoreResult;      // points + issues
    fn rubric() -> &'static RubricDef;
    fn max_score() -> u16;
}

pub struct MissionDef { pub id: &'static str, pub name: &'static str, pub image: &'static str, pub fields: &'static [FieldDef] }
pub struct FieldDef { pub id: &'static str, pub label: &'static str, pub kind: FieldKind, pub requires: Option<&'static str> }
pub enum FieldKind { Bool, Count { max: u8 }, Choice { options: &'static [&'static str] } }
pub enum Answer { Bool(bool), Count(u8), Choice(u8) }
pub type Answers = BTreeMap<String, Answer>;
pub struct ScoreResult { pub total: u16, pub per_mission: Vec<(String, u16)>, pub issues: Vec<Issue> }
pub struct RubricDef { pub sections: &'static [RubricSection] }   // IP, RD; each with rows { id, label, descriptors: [&str; 4], core_values: bool }
```

Scoring example shape (BIOGLOW M04, written once with both points and validation):

```rust
fn m04(a: &Answers, out: &mut ScoreResult) {
    let leaves = a.count("m04_leaves");              // 0..=2
    let katydid_in = a.bool("m04_katydid_in_habitat");
    let bonus = a.bool("m04_bonus_original_position");
    if bonus && !(leaves == 2 && katydid_in) {
        out.issue("m04_bonus_original_position", "Bonus needs both leaves removed and the katydid in the habitat");
    }
    let pts = match (leaves >= 1 && katydid_in, leaves == 2 && katydid_in && bonus) {
        (_, true) => 30, (true, _) => 10, _ => 0,
    };
    out.add("m04", pts);
}
```

Tests per season: defaults score 0 with no issues; `max_score()` is reachable; a table of answer sets with expected totals cross-checked against the official Excel scorer formulas (the extracted formulas from the research are the test oracle); every `requires` relationship produces an issue when violated.

Registry: `pub fn by_id(id: &str) -> Option<&'static dyn SeasonDyn>` using an object-safe wrapper so the server can look up a season from `events.season_id`. The client renders forms purely from `missions()` and `rubric()`, so adding a season is one file plus images plus tests.

Port order: BIOGLOW Founders (from Legacy `fll_2026.rs` + official scoresheet), then UNEARTHED, SUBMERGED, MASTERPIECE. BIOGLOW Future Edition is a separate season module only if a Future event is ever run.

## 12. Scheduling (`tms-schedule`)

Inputs (`GenerateRequest`): day windows, blocks (lunch, ceremonies), teams, tables (pairs), pods, ranking rounds, practice rounds, match cycle minutes, judging session minutes and buffer, judging-match gap, max teams per pod, options (judging first / interleaved, alternate sides, keep round order).

Algorithm:

1. Build judging slots: for each pod, consecutive sessions from the judging window, skipping blocks, capped at `max_teams_per_pod`. Fail early if `pods × capacity < teams`.
2. Build match slots: for each round, consecutive matches on the match window at the cycle length, each with one slot per table; number of matches per round = `ceil(teams / tables)`.
3. Initial assignment: shuffle teams; assign judging round-robin over pods and sessions; assign matches by cycling teams through tables with a side alternation and a rotation offset per round.
4. Local search (simulated annealing, fixed iteration budget, seeded RNG for reproducibility): moves are swap two teams' judging slots, swap two teams within a round, move a team to an empty slot. Penalty = hard violations × 10⁶ (overlap with own judging ± gap, two matches in one cycle, pod over capacity, team missing a match) + soft terms (variance of gaps between a team's activities, same table twice, same opponent twice, back-to-back cycles, matches within X minutes before judging).
5. Output a `ScheduleProposal` with matches, slots, sessions, judging slots and the issue list from `tms-core::validation`. Zero hard issues is required to commit unless `force`.

Manual edits reuse the same validation: changing a slot's team or a match's time runs the checks for the affected teams and returns issues inline before saving. `reschedule-team` enumerates candidate slots for one team and ranks them by penalty.

Import: Tournament-in-a-Box Version 1 CSV parsed with the `csv` crate (quotes handled), AM/PM honoured, times combined with the event date, practice and ranking matches numbered in separate rounds so they never collide. Dry-run shows the proposal and issues before commit.

Exports back out: the same CSV format (so other FIRST Australia tools can consume it) and the per-team CSV.

## 13. Offline and sync

### 13.1 Session modes

| Mode | How entered | Can do |
|---|---|---|
| Online user | password login | everything the role allows |
| Online key | key verified by server | role from server, bindings from key |
| Offline-unverified key | key entered with no server | role from prefix; read cached topics; create scoresheets/rubrics into outbox; no server actions |
| Anonymous | none | public displays if the event allows |

When an offline-unverified session later reaches the server, the client calls `POST /auth/key`; if the key is invalid or revoked the session is flagged, the outbox is kept (so nothing is lost) and an admin can re-key the device; if valid the mode flips to Online key and the outbox drains.

### 13.2 Local store (IndexedDB)

Database `tms`, stores: `session` (one record), `outbox_scoresheets`, `outbox_rubrics` (keyed by document id; fields: document, status Pending | Sent | Accepted | NeedsBinding | Rejected, last_error, attempts), `cache` (topic → snapshot + received_at), `prefs`.

Cached snapshots make the stations and queue board readable offline. They are written on every snapshot and debounced on deltas.

### 13.3 Sync protocol

`POST /api/v1/sync/scoresheets` with `{ documents: [Scoresheet] }` and the key or session bearer. Response `{ results: [{ id, outcome }] }` where outcome is one of:

- `Accepted { status }` (Submitted or Published)
- `Duplicate` (already stored; treat as accepted)
- `NeedsBinding { reason }` (unknown team number, missing round)
- `Rejected { code, message }` (wrong event, wrong season, schema mismatch, invalid or revoked key, validation failure with issues)

The worker runs on connectivity change, on `visibilitychange` to visible, on a 30 s interval while pending, and immediately after a submit. Batches of up to 50. Rejected documents stay local until a human acts on them in Settings. The server stores every accepted document verbatim in `answers` so later re-scoring is possible if a season has a scoring bug.

### 13.4 Event and version guards

A document carries `event_id`, `event_code`, `season_id`, `schema_version`. The server accepts only documents whose `event_id` is the active event (or an event the key belongs to), whose season matches, and whose schema version is one the server's season crate knows. A device left with sheets from a previous event shows them under Settings with an "other event" tag, and they are never sent to the current event.

## 14. Integrity checks (designed now, built late)

Connor's question was how real systems do warning/error passes without rescanning everything. The answer is scoped recomputation:

- Each check declares a scope: `Team(id)`, `Match(id)`, `Session(id)`, `Event`. Each domain event maps to the scopes it dirties (a slot change dirties its match and its team; a schedule replace dirties the event).
- An `issues` table stores `(code, severity, scope, refs, message)`. On a dirty scope the service deletes that scope's issues and recomputes only the checks for that scope using targeted queries. Event-scope checks (duplicate team numbers, team with fewer matches than the maximum) run on schedule commits and on team CRUD, not on timers.
- Checks are the Legacy E/W catalogue reduced to what the schema does not already enforce. Many of them become constraints or impossible by construction: E001/E002/E004/E005/E006/E008/E009/E012 (uniqueness and FK), E003 (partial unique index), W007/W008/W017/W018 (not null).
- Remaining checks live in `tms-core::validation` as pure functions over small input structs, reused by the generator, the manual editor and the issue service. That is how the "duplicated logic" problem goes away: one function per check, three callers.

Build this in Phase 7 after scheduling. Until then the manual editors call the hard-constraint checks inline.

## 15. Security

- Passwords: argon2id, forced change on first login for the bootstrap admin, password from `--admin-password` on first start or generated and printed once; recovery through the launcher window.
- Login tokens: HS256 JWTs. A password login lasts 12 h and a key login 24 h, both refreshable. Revocation is instant through the in-memory list (ADR-7). Keys: 12-char Crockford base32 after the role prefix (60 bits), SHA-256 stored, event-scoped, revocable, optional expiry.
- Transport: HTTPS mandatory outside localhost (ADR-5). HSTS on. No CORS needed when the client is served from the same origin; if `dx serve` proxies in dev, no CORS either.
- Authorization: every handler declares the required role through an extractor; role inheritance is one function in `tms-core::auth` used by server and client (client only for UI gating).
- Rate-limit `/auth/login` and `/auth/key` (tower middleware, per IP). Login errors do not reveal whether the username exists.
- Audit every state transition and admin edit with actor (user or key label).
- Judging data is confidential: rubric topics and deliberation are never sent to non-JA connections; exports with rankings are JA/Admin only; the public scoreboard shows robot scores only.
- Backups: interval `pg_dump` backups with retention, created by the server. Restore and purge happen from the launcher window, never from the web UI, because they need the server stopped (section 17.1). The embedded PostgreSQL listens on 127.0.0.1 only, with a random password stored in the data folder.

## 16. Testing

| Layer | What | How |
|---|---|---|
| tms-core | state transitions, ranking, deliberation maths, validation | unit tests; property tests for ranking (`proptest`) |
| tms-seasons | each season's scoring vs official scorer vectors; defaults; max; requires | unit tests, one file per season |
| tms-schedule | generator produces zero hard issues for team counts 6-40 with 1-6 pods and 2-6 tables; determinism with a seed; importer round-trips a TiaB CSV | unit + snapshot tests |
| tms-server | repo queries (compile-time checked), service flows (stage → start → end → score → rank), sync outcomes, auth, WS snapshot/delta | `#[sqlx::test]` with migrations against a Postgres from testcontainers or a local `DATABASE_URL`; WS tests with `tokio-tungstenite` |
| tms-client | status mapping, form rendering from season defs, outbox state machine | unit tests on pure modules; a small number of `dioxus-ssr` render tests for components |
| End to end | referee submits offline, reconnects, sheet publishes, scoreboard updates | manual checklist per phase; optional Playwright later |

CI: `cargo fmt --check`, `cargo clippy --all-targets -- -D warnings`, `cargo test --workspace`, `cargo sqlx prepare --check`, `dx build --release --package tms-client`, docker image build. Keep TMS-2's pre-commit config and `typos`.

## 17. Deployment and operations

- Event laptop (the normal case): unzip the release folder, double-click `tms`, press Start. PostgreSQL is inside the program and the web client is the `web` folder beside it (ADR-13).
- Headless host (a mini PC, a VM, a Raspberry Pi-class box): `tms --headless`, optionally under systemd or as a Windows service (unit and service examples in the ops docs, Phase 8).
- Larger or shared setups: `tms --headless --database-url postgres://...` against an external PostgreSQL.
- Data folder (`--data-dir`, default `data/` next to the program, so the whole install is one movable folder):
  - `tms.toml` (configuration)
  - `postgres/` (embedded binaries and data)
  - `backups/`
  - `logs/`
  - `certs/`

  Pointing `--data-dir` at a USB stick makes a portable install.
- Configuration precedence: command-line flag, then environment variable, then `tms.toml`, then built-in default. Every setting has all three forms, and `tms --help` lists them.
- Migrations run on startup (`sqlx::migrate!`), with a `--no-migrate` flag.
- Logs: `tracing` with JSON to stdout and a rolling file; request ids; WS connection lifecycle at info.
- Health: `/healthz` (DB ping) and `/version` (git sha, season crate ids, schema versions). The client shows version mismatch in Settings.
- Time: the server is the clock. Event timezone is a setting; everything is stored UTC.

### 17.1 Launcher and command line

#### Flags only (decided by Connor, 2026-10-29)

`tms` has no subcommands. It is one program with settings flags:

- `tms` opens the launcher window.
- `tms --headless` (alias `--no-gui`) runs the server in the terminal. It prints the join URLs and a QR code, and Ctrl+C stops it.

Everything else is done in a UI:

- **Launcher window:** logs folder, backups (create, restore, import), database export and import, password recovery, purge.
- **Web client:** CSV exports of teams, scores, rankings and rubrics.

Inspecting the database means connecting any PostgreSQL tool to it. Run with `--db-port` for a fixed port; the password is in `<data>/postgres/password`.

Settings (each also a `TMS_*` environment variable and a `tms.toml` key):

| Setting | Default |
|---|---|
| `--bind` | `0.0.0.0` |
| `--port` | `8080` (HTTP) |
| `--tls-cert`, `--tls-key` | none; when set, serves HTTPS |
| `--tls-port` | `8443`; with TLS, plain HTTP on `--port` redirects to HTTPS |
| `--public-host` | Hostname or IP used for the printed URL and QR code. Default is the first LAN IPv4 address, or the certificate's name when TLS is on |
| `--data-dir` | `data/` next to the program |
| `--database-url` | Unset, which means embedded PostgreSQL |
| `--db-port` | Free port on 127.0.0.1 (embedded only) |
| `--admin-password` | Bootstrap password, used only when no users exist |
| `--backup-interval`, `--backup-retain` | 10 minutes, 20 |
| `--log-level` | `info` |
| `--web-dir` | `web/` next to the program (a debug build falls back to the workspace's `dx build` output) |
| `--supervised` | Set by the launcher (see below) |

#### Supervision protocol (launcher ↔ `tms --headless --supervised`)

- **Status:** the child writes one JSON status line per lifecycle step to stdout. Ordinary logs go to the log file, and stderr carries panics. The steps are:
  - `{"status":"starting_database"}`
  - `{"status":"migrating"}`
  - `{"status":"listening","urls":["http://192.168.1.20:8080", ...]}`
  - `{"status":"stopping"}`
  - `{"status":"stopped"}`
  - `{"status":"fatal","message":"port 8080 is already in use"}`
- **Stop:** the launcher writes `stop` to the child's stdin, which triggers a graceful shutdown. This works the same on Windows, macOS and Linux and avoids signal differences. If the child has not exited after 10 seconds, the launcher kills it.
- **Launcher exit:** if the launcher dies, the child's stdin closes, and the child treats that as `stop`. Neither the server nor the embedded PostgreSQL is left running unowned.
- **Liveness:** the launcher also polls `/healthz` every 5 seconds while running, so a hung server shows as "Not responding" rather than "Running".
- **Windows console:**
  - the binary is built with `windows_subsystem = "windows"`, so double-clicking it shows no console
  - `tms --headless` run from a terminal attaches to the parent console
  - the child is spawned with `CREATE_NO_WINDOW`

#### Launcher window

One small window, about 560 × 680, square and utilitarian like the web app, in light or dark following the OS.

- **Header:**
  - a status pill: Stopped, Starting (shows the current step), Running (with uptime), Not responding, Stopping, Exited, or Crashed
  - Start, Stop and Restart buttons
- **Connect tab:**
  - a large QR code for the join URL
  - a drop-down of detected addresses (every LAN IPv4, plus the public host)
  - Copy URL, Open in browser, and Save QR as PNG for printing
- **Server tab:**
  - bind address, HTTP port, HTTPS toggle with certificate and key file pickers, HTTPS port, public host
  - bootstrap admin password, which is only editable before first start
  - log level
  - fields are locked while the server runs; changing one offers "Restart to apply"
- **Database tab:**
  - Embedded: data folder, port, size on disk
  - External: connection URL and a Test connection button
- **Backups tab:**
  - list of backups with date, size, app version and event codes
  - Create now, Restore, Import file, Open backups folder, plus the interval and retention settings
  - Restore asks for confirmation, stops the server, restores, and starts it again, showing each step
- **Logs tab:**
  - live tail of the last 500 lines with a level filter
  - Open logs folder, Copy last 100 lines
- **Footer:**
  - the exact equivalent command line (`tms --headless --port 8080 ...`) with a copy button, so a technical user can move to headless with identical settings
  - a Maintenance menu: reset admin password, open data folder, about and version
- **Error popup:** shown on a `fatal` status or any non-zero exit. It contains:
  - the message in plain words, the exit code, and the last 20 log lines
  - buttons for Open logs, Copy details and Restart
- **Closing the window while running** asks "Stop the server and quit?" A "minimise to tray" option can come later with `tray-icon`.

Crates:

| Crate | Purpose |
|---|---|
| `eframe`/`egui` | Window and UI |
| `qrcode` | QR in the window and as Unicode in the terminal |
| `local-ip-address` | LAN addresses |
| `directories` | Platform data folder |
| `rfd` | File dialogs |
| `opener` | Open folders and URLs |
| `toml` | Config file |
| `postgresql_embedded` | Embedded database (used by `tms-server`) |

#### Backups (moved here from Phase 8, because the launcher is where they belong)

- **Format:** one `.tmsbackup` file per backup. It is a zip of a `pg_dump` custom-format dump plus `manifest.json`, which records:
  - the app version
  - the migration version
  - the event codes and created time
- **Tools:** the embedded PostgreSQL bundle provides `pg_dump` and `pg_restore`. With `--database-url`, backups use those same bundled tools against the external server.
- **Restore:**
  - stops the server
  - runs `pg_restore --clean` into the database
  - runs migrations, which allows restoring an older backup into a newer app
  - starts the server
- **Refused restores:**
  - a backup from a newer migration version than the app
  - any restore while a server is running on the same data folder

### 17.2 API documentation

- Docs site: Material for MkDocs, or its successor Zensical from the same team. Both build the same Markdown tree in `docs/`. Keep TMS-2's `gh-pages.yml` shape.
- REST: `utoipa` generates the OpenAPI 3 document from the handler and DTO annotations; served at `/api/docs` and exported to `docs/api/openapi.json` by `tms-server export-openapi` in CI.
- WebSocket: `ClientMessage`, `ServerMessage` and `Topic` derive `schemars::JsonSchema`; `cargo test` rewrites `docs/api/schemas/*.json`. A hand-written `docs/api/websocket.md` describes the handshake, the subscription model, topics with their string forms, heartbeat and clock sync, and links the schemas. This is the page an outsider reads to consume the live feed.
- Every page in `docs/roles/` describes one role's screens and actions, as Legacy did.

---

# Part C: When

## 18. Phased delivery

Each phase ends with a demo and the listed checks. Phases are ordered so that a usable robot-game event is possible after Phase 3, the offline promise is kept by Phase 4, and judging follows.

### Phase 0: Foundations (workspace, DB, auth, shell)

Deliverables:

1. Workspace per section 5 with `tms-core`, `tms-server`, `tms-client`, `tms-ui` skeletons; lints and formatting from TMS-2; CI.
2. Docker Compose with Postgres; migrations for events, users, sessions, access_keys, settings, audit_log, banners.
3. Server: config, `AppState`, `/healthz`, `/version`, static serving with SPA fallback, TLS, `auth/login`, `auth/key`, `auth/me`, `RequireRole` extractor, error type, audit helper, `create-admin` CLI.
4. WS hub with `Hello`, `SetSubscriptions` (diff, snapshot on add, topic-tagged fan-out), `Ping/Pong`, `TimeSync`, `Banner`, `Event` topic. Schema export command and the websocket docs page.
5. Client: router, `AppShell` with TopBar and BannerSlot, theme tokens light/dark, login page (password and key), session store, realtime task with reconnect, clock sync and the ref-counted `use_subscription` registry, Settings page shell.
6. `tms-ui` primitives: Button, Badge, Card, DataTable, Select, TextField, Modal, Toast, Banner.
7. HTTPS plan executed once: a cert that works on an iPad on the LAN; service worker registers.

Verify: `cargo test` green; login as admin from an iPad over HTTPS; disconnect the server and watch the connection pill and banner change; reconnect restores. WS clock offset shown in Settings within ±50 ms on LAN. Hub test: two components subscribe to `teams`, one unmounts, the server still forwards; both unmount, the server stops within one debounce; a reconnect resends the exact set.

#### Phase 0 status (2026-10-29)

Done and verified:

- Workspace, lints (as `[workspace.lints]`), rustfmt, CI workflow, foundation migration, `.sqlx` offline data. (A Docker Compose file existed here and was removed in Phase 0b.)
- Server:
  - config, and TLS via `axum-server` with rustls/ring
  - static client with SPA fallback and pre-compressed assets, plus `/healthz` and `/version`
  - auth: password login, key login, JWT refresh, logout, me, and change password (returns a fresh token)
  - per-address login rate limiting
  - events (create, list, active, activate), access keys (create, list, revoke) and banners (create, list, clear)
  - audit rows on every admin write
  - bootstrap admin on first start
- Auth: HS256 JWT with an in-memory revocation list (ADR-7). Revocations close live WebSockets.
- Live feed:
  - hello/welcome with token, and `set_subscriptions` diffing with a snapshot on add
  - one serialisation per message on the bus
  - resnapshot on event activation and on lag
  - ping/pong and time sync
- Client:
  - router, and a shell with a top bar (event, synced event-timezone clock, connection, roles, theme, log out), one banner slot and side nav
  - login by password or access key, including offline key login with later verification
  - forced password change, background token refresh, home
  - settings: theme, connection, login, and the live subscription registry
  - ref-counted `use_subscription`
- Tests:
  - 18 unit tests
  - 16 server integration tests (`#[sqlx::test]`, real HTTP and WebSocket)
  - a 28-check headless Chrome run that lives outside the repo
- Release client: 1.17 MB WASM, 341 KB brotli.

Differences from the text above, by decision:

- `Hello` carries a login token only (see section 8.3).
- Topics exist only for `event` and `banners`; each later phase adds its own.
- The session lives in localStorage. IndexedDB arrives with the outbox in Phase 4.
- No Toast component yet, because nothing needs one yet.
- Fonts use the system stack; self-hosted Inter is Phase 8 polish.
- REST docs are hand-written plus generated JSON Schemas; `utoipa` OpenAPI is not added.

Resolved on the same day:

- iPad offline install is deferred by decision (ADR-5).
- JWT replaced database sessions.
- Login rate limiting is built.
- Revocations close open WebSockets.
- All "staff" wording is gone.

Phase 0 is complete.

### Phase 0b: Single binary (embedded database, embedded client, flags)

Comes straight after Phase 0, so every later phase is developed and tested the way it ships.

Deliverables:

1. New `tms-launcher` crate producing the binary `tms`. `tms-server` becomes a library: its `main.rs` moves into the launcher.
2. Configuration via `clap` flags plus `TMS_*` environment variables plus `tms.toml`, with the precedence and settings table from section 17.1. `--data-dir` and the platform default folders.
3. New `tms-db` crate: embedded PostgreSQL through `postgresql_embedded` (bundled PostgreSQL 17), plus pool setup and migrations moved out of `tms-server`:
   - first-start unpack and `initdb`
   - random password in the data folder, bound to 127.0.0.1 on a free port
   - clean stop on shutdown, and stale-pid recovery after a hard kill
4. `--database-url` switches to an external server and skips the embedded one.
5. Web client release build compiled into the binary with `rust-embed`, including the `.br`/`.gz` variants. `--static-dir` remains a development override. (Replaced on 2026-10-29 by the `web/` folder in the release zip; see ADR-13.)
6. On start: print every join URL and a Unicode QR code in the terminal. The default bind is `0.0.0.0`.
8. Release build script that runs `dx build --release` and then `cargo build --release -p tms-launcher`, so the client is embedded. The binary size is recorded.

Verify:

- On a machine with no PostgreSQL and no Docker, `./tms --headless` starts, serves the app, and the Phase 0 browser checks pass against it.
- A second start reuses the data.
- `kill -9` of `tms` followed by a restart recovers without manual cleanup.
- `--database-url` against an external PostgreSQL works.
- No `postgres` process outlives `tms` after Ctrl+C.

#### Phase 0b status (2026-10-29)

Done and verified. Phase 0b is complete.

- **`tms` binary:**
  - flags only, per section 17.1
  - `tms` and `tms --headless` both serve in the terminal until the launcher window exists
  - configuration from flags, then `TMS_*` environment variables, then `tms.toml`, then defaults
  - unknown `tms.toml` keys are rejected
  - daily log files in `<data>/logs`, 14 kept
  - join URLs and a terminal QR code printed at start
  - Ctrl+C or SIGTERM stops gracefully
- **`tms-db` crate:**
  - bundled PostgreSQL 17.11 bound to 127.0.0.1, with a password generated once and stored readable only by the owner
  - an exclusive lock on the data folder, so a second `tms` on the same folder is refused
  - after a hard kill, a leftover server is stopped and a stale pid file is handled
  - `--database-url` uses an external server instead
- **Web client compiled in:**
  - pre-compressed copies are served when the browser accepts them
  - hashed assets cache forever, while `index.html` revalidates
  - unknown client routes fall back to `index.html`, but missing files return 404
  - added a `favicon.ico`
- **HTTPS:** `--tls-cert`/`--tls-key` serve HTTPS on `--tls-port`, and plain HTTP redirects there with the host and path kept.
- **Release:** `scripts/release.sh` builds one 61 MB program. CI builds it for Linux, Windows and macOS.
- **No Docker anywhere:**
  - builds check SQL against the committed `.sqlx/` data (`SQLX_OFFLINE` defaults on)
  - server integration tests each start their own embedded PostgreSQL
  - the dev database is the dev server's own, on `--db-port`
- **Tests:**
  - 47 Rust tests, including real embedded-PostgreSQL restart, orphan recovery, folder lock and external URL
  - 36 checks of the release program (first start, compressed client, Ctrl+C, restart, `kill -9` recovery, busy port, external database, HTTPS redirect, flags only)
  - the 28 browser checks, run against the release program

Removed by decision:

- the `db`, `admin` and `export-schemas` subcommands
- Docker Compose
- `.env`

The API JSON Schemas for the docs are rewritten by `cargo test`.

### Phase 1: Event setup

Deliverables: events CRUD and activate; settings page; teams, tables, pods, rounds, schedule blocks CRUD; users and access keys pages (key shown once with QR); TiaB CSV import dry-run and commit; topics for teams/tables/pods/rounds/blocks; dashboard tiles by role; audit page.

Verify: import a real Tournament-in-a-Box export from a past FIRST Australia event; counts match; re-import replaces instead of duplicating; a referee key logs in on an iPad with its table pre-bound.

#### Phase 1 status (2026-10-29)

Done and verified. Phase 1 is complete.

- **`tms-schedule` crate:**
  - Tournament-in-a-Box CSV parser that reports every problem in the file with its line number
  - handles quoted names, trailing-comma differences, and the 24-hour-with-AM/PM time quirk
  - day labels become event dates, and local times become UTC through the event timezone
  - each team's matches are numbered into rounds per kind
  - tested against the three real Legacy sample files; the "broken" one imports with a warning naming the three unjudged teams
- **Migration 2:** event settings (JSON with defaults), teams, tables, pods, matches with slots, judging sessions with slots, timetable blocks, and key bindings to a table or pod. Deleting a team, table or pod that the schedule uses is refused by the database and explained to the user.
- **Server:**
  - CRUD for teams, tables and pods (with ordering) and timetable blocks
  - schedule import, as a dry-run preview or an atomic replace
  - event edit and settings validation, archiving (which revokes the event's keys), and a seasons list
  - users: create with a one-time password, roles, disable, reset; a user can't remove their own admin access, and the last admin can't be removed
  - access keys bound to a table or pod, with the binding carried in the login token
  - a paged, filtered audit log
  - live topics `teams`, `tables`, `pods`, `matches`, `judging_sessions` and `blocks`
- **Client:**
  - an Event setup area (admins only) with tabs: Event, Teams, Tables & pods, Schedule, Users, Access keys, Audit log
  - every list is live, so another session's change appears without reloading
  - access keys are shown once with a QR code; times are shown in the event's timezone
- **Tests:** 65 Rust tests (17 Phase 1 server tests), 40 Phase 1 browser checks against the release program, and the Phase 0 and binary suites still green.

Changes to the plan, by decision:

- There is no `rounds` table. A match is practice or ranking. Each slot carries the team's round number (its nth match of that kind), which is how FLL schedules work and how Legacy counted.
- Slots travel inside their match or session item on the live feed rather than as separate topics.
- Live-feed items are `{"kind": ..., "data": {...}}`. With the tag inside the item, a `kind` field on a match or block would collide.
- Timetable blocks are entered as event-local times, and the server converts them, so browsers need no timezone database.
- Logging is `tracing` with daily-rotated files in `<data>/logs`, 14 kept.

### Phase 2: Robot game core

Deliverables: matches and slots from the import; match state machine and endpoints; timer service and `Timer` messages; HR control page; referee station; BIOGLOW season in `tms-seasons` with tests; scoresheet form; online submit path (outbox exists but device is online); server validation and recompute; HR review queue with AutoPublish and HeadRefereeReview modes; ranking in `tms-core`; scoreboard and timer displays; emcee page; audio on displays.

Verify: run a full simulated round with 12 teams and 2 tables: stage, countdown, run, end, two referees submit, HR sees sheets, scoreboard ranks update within a second; scoring tests match the Excel scorer vectors; abort then restart cannot double-fire (test); server restart mid-match restores the timer state.

#### Phase 2 status (2026-10-29)

Done and verified. Phase 2 is complete.

- **`tms-seasons` crate:**
  - a `Season` is static data (missions, fields, defaults, prerequisites) plus one scoring function, shared by the browser and the server
  - BIOGLOW Founders follows the official software scoresheet's wording and the official Excel scorer's points
  - issues are errors (block submit) or warnings (the M14 seed check), and a bonus is reset when its prerequisite goes back to No
  - 13 tests, including the Excel formulas transcribed as an oracle over 20,000 random sheets
- **Migration 3:** match state, one match timer per event (with a `run_id` that changes on every start, abort and early end), and scoresheets with a one-published-sheet-per-round index.
- **Server:**
  - match actions: stage (refused if another staged match uses the same tables, or if an earlier match on those tables is unscored, unless forced with a reason), unstage, cancel, reset
  - timer: start (with or without countdown), abort (matches go back to staged), end now, automatic phase changes, and resume after a restart (a run that should have ended while the server was down ends at once)
  - `POST /sync/scoresheets`: batch of up to 50, idempotent by id, with accepted, duplicate, needs-binding and rejected outcomes; the server recomputes every score
  - auto-publish, unless the sheet has warnings, a changed total, or a round already published; head referee review mode holds every sheet
  - publish (supersedes the earlier sheet for the round), reject with a note, unpublish
  - ranking by best, then second, then third score, with shared ranks for ties
  - live topics `timer` and `rankings` (public) and `scoresheets` (referees)
  - `tms-db` gained a build script so a new migration file always rebuilds the embedded migrations
- **Client:**
  - Match control (head referee): match list with stage and other actions, timer panel, waiting-for-scoresheets strip, force-stage dialog
  - Scoresheets review: filter, answers per mission, publish, unpublish, reject with a reason
  - Referee station: table from the key binding or a device choice, now, to score, up next, this table's sheets with rejection notes
  - Scoresheet form rendered from the season definition, with mission images, live total, inline problems, GP buttons and comment, team agreement, no-show, and unscheduled sheets
  - Emcee page, full-screen timer display with sounds, and a paging scoreboard display, both without a login
- **Tests:** 7 new server tests (full match, review, review mode, bad sheets, staging rules, abort then restart, resume after restart) and 58 Phase 2 browser checks against the release binary.

Changes to the plan, by decision:

- The timer is started, aborted and ended per event (`/events/{id}/timer/...`), not per match. It runs every staged match together, which is how the field works.
- `reopen` became `reset`: a finished or cancelled match goes back to scheduled to replay it. A replay's new sheet supersedes the old one through review.
- Staging is allowed while another match runs, so the next match can be called during the current one.
- A match has no stored Scored state. Each slot shows its sheet status, and "unscored" is derived.
- A total that differs from the server's is kept with the server's total and sent to review, not rejected, so a sheet is never lost to a client bug.
- Ended and aborted stay on the clock until the next start, instead of returning to idle after 2 seconds.
- Not in Phase 2: queue states and the readiness gate (Phase 3), the offline outbox (Phase 4), hiding scores until a round is published, and editing a sheet's answers as head referee.

### Phase 3: Integrated queueing

Deliverables: slot queue state machine with audited events; queue endpoints; queue board page with action dropdowns and server feedback; "Now calling" strip; referee station actions `Team at table`, `Ready`, `No show`; HR start gate on slot readiness with force; queue display; presence topic (connected table keys) on HR control.

Verify: queuer calls a team, referee marks at table and ready, HR sees the gate open; a no-show flows to a Scratched/NoShow slot and the ranking ignores it; every transition appears in the audit log with actor.

#### Phase 3 status (2026-10-29)

Done and verified. Phase 3 is complete.

- **Queue state machine** in `tms-core::queue`: not called, called, on the way, in queue, at table, ready, playing, done, no show, scratched. Actions check both the state and the role. Queuers call and send teams; referees take a team at the table (also straight from not called) and mark it ready; either can mark a no-show; scratching and undoing a no-show are the head referee's. Undo returns to the state before the last change.
- **Migration 4:** queue state, previous state and who changed it on each slot, plus `slot_queue_events` with every change and its actor.
- **Server:**
  - `POST /slots/{id}/queue`, audited as `slot.<action>`
  - the timer moves teams to playing on start, done on end, and back to ready on abort; a reset match starts its queue again
  - start waits until every team is ready, a no-show or scratched (event setting, on by default); the head referee can start anyway with a reason, which is audited along with the teams that were not ready
  - a no-show or scratched slot needs no scoresheet, so it never blocks staging
  - `presence` topic: access-key devices connected now, from the live feed's own connections
- **Client:**
  - Queue board: Now calling (inside the event's calling window, default 15 minutes), upcoming matches with each team's state and the actions this login may take, a table-pair filter, a team search that shows the team's whole day, and a warning when a team's judging session is within the gap of a match
  - Referee station: the Now card is the staged match or this table's next one, with Team at table, Ready and No show
  - Match control: queue states on every slot, "Waiting for" with the teams holding up the start, Start anyway with a reason, and a Stations panel showing each table's device
  - Queue display for the pits, without a login; event settings for the gate and the calling window
- **Tests:** 5 new server tests and 27 Phase 3 browser checks; the Phase 2 tests now mark teams ready before starting.

Changes to the plan, by decision:

- "Staged" in the queue is called "In queue" (`waiting`), so it can't be confused with a staged match.
- Ready can be marked from any state before the match, so a referee isn't forced through every step.
- The readiness gate is an event setting, because some events run without queuers and referee tablets.
- Queue actions have no offline outbox, as planned: they are time-sensitive and the server owns them.

### Phase 3b: Launcher window and backups

Placed here because after Phase 3 the system can run a real robot game, and a non-technical tournament director needs to start it without a terminal.

Deliverables:

1. `--supervised` mode for `tms --headless`: JSON status lines and stop-on-stdin, per section 17.1.
2. The egui launcher (`tms` with no arguments):
   - header status and Start/Stop/Restart
   - Connect tab with QR and address picker, Server tab, Database tab with external connection test, Logs tab
   - equivalent command-line footer
   - error popup with exit code and last log lines
   - "stop and quit" on close
3. Backups:
   - `.tmsbackup` format
   - interval backups with retention, run by the server
   - Backups tab with create, restore (stops, restores, restarts the server) and import
   - database export and import from the same tab
4. Maintenance menu: purge an event's data (typed confirmation), and reset a user's password (one-time password, forced change, ends that user's logins).
5. Windows: no console on double-click, attach to the parent console for `tms --headless` run from a terminal.

Verify:

- Double-click the binary, press Start, scan the QR code from a tablet, and log in.
- Occupy port 8080 first: the launcher shows "port 8080 is already in use" in the error popup.
- Back up, change data, restore: the data matches the backup.
- Close the launcher while running: no `tms` or `postgres` process remains.
- Kill the launcher process from the task manager: the server shuts itself down within seconds.
- Copy the footer command line into a terminal: the server starts with identical settings.

#### Phase 3b status (2026-10-29)

Done and verified, with the gaps listed below. First, the release format changed at Connor's request: a release is a zip folder with the `tms` program and a `web/` folder, not one binary with the client inside (ADR-13).

- **Supervision protocol** (`tms --headless --supervised`): JSON status lines on stdout (`starting_database`, `migrating`, `admin_password`, `listening`, `backup_created`, `backup_failed`, `stopping`, `stopped`, `fatal`), and `stop` or `backup` on stdin. Logs go to the file only. A closed stdin stops the server, so it never outlives the launcher. Tested against the real program, including a port already in use (fatal with the message, non-zero exit).
- **Backups** in `tms-db::backup`: `.tmsbackup` zip files with a `pg_dump` custom dump and a manifest (app version, migration version, time, kind, event codes). Automatic backups run in the server every `--backup-interval` minutes (default 10, 0 for none) and keep `--backup-retain` (default 20); manual ones are never pruned. A restore makes a "before restore" backup, empties the schema, runs `pg_restore`, then the current migrations. A backup from a newer TMS is refused. External databases use the bundled `pg_dump`.
- **Maintenance** in `tms-server::maintenance`, run by the launcher with the server stopped: reset a user's password (one-time, forced change, re-enables a disabled user, ends their logins) and delete an event with everything in it (typed event code). Both audited as `launcher`.
- **Launcher window** (`tms` with no flags), eframe/egui, square corners and the TMS teal, light or dark following the system:
  - header: status (Stopped, Starting with the step, Running with uptime, Not responding, Stopping, Stopped with an error) and Start, Stop, Restart
  - Connect: address picker, QR code, Copy address, Open in browser, Save QR code as SVG, and the first-start admin password
  - Server: listen address, ports, public host, HTTPS with file pickers, log level, first admin password (before the first start only); locked while running, with Restart to apply
  - Database: built-in or an existing PostgreSQL with Test connection; folder, fixed port, size on disk
  - Backups: list with time, kind, size and events; Create now, Import file, Open backups folder, Restore (stops the server, restores, starts it again), interval and retention
  - Logs: last 500 lines of the newest log file with a level filter, Open logs folder, Copy last 100 lines
  - footer: the equivalent `tms --headless ...` command with Copy, and a Maintenance menu (reset a password, delete an event, open data folder, about)
  - error popup on a crash with the message, exit code and the last log lines; closing while running asks "Stop the server and quit?"
  - starting saves the settings to `data/tms.toml`, so `tms --headless` in the same folder behaves the same
- **Windows:** release builds are window programs (no console on double-click) and attach to the parent console for `tms --headless` in a terminal. Not tested on Windows yet.
- **Tests:** backups (2), maintenance (2), the protocol (3), the form, logs and status units, and a window test that clicks through Start, backup, Stop, restore, password reset and Start against the real program. A screenshot test renders every tab without a screen.

Not done in Phase 3b:

- Database export and import beyond backup files (a backup is the export; importing one is the import).
- The manual verification steps above on a real desktop, tablet and Windows machine.
- Minimise to tray.

### Phase 4: Offline and keys

Deliverables: IndexedDB store; outbox worker; sync endpoint with per-item outcomes; Settings history page with bind/retry/clear; event and schema guards; cached topic snapshots so an open page keeps showing data offline; `visibilitychange` resync. (Offline key login is already in Phase 0. The installable service-worker app is deferred to Phase 9, per ADR-5.)

Verify: in a browser on a tablet, open the station, turn Wi-Fi off, add three scoresheets (one unbound), turn Wi-Fi on: two publish, one shows Needs binding, bind it, it publishes. Enter a key while the server is unreachable, score, reconnect: sheets sync. A sheet from an archived event is refused with a clear reason.

#### Phase 4 status (2026-10-29)

Done and verified. Phase 4 is complete.

- **Outbox** (`store/outbox.rs`): every scoresheet is saved on the device first, then sent in batches of up to 50. It retries when the live feed reconnects, when the page becomes visible, every 10 seconds while sheets are waiting, and right after a submit. Outcomes are kept per sheet: waiting, sent (with its status), needs a team or round, or refused.
- **Form:** Submit saves to the outbox and waits up to 3 seconds for the server's answer. A sheet the server can't place stays open to fix; otherwise the station says whether it was published, is waiting for review, or is saved on the device until the server can be reached. The station shows a warning while sheets are waiting or need attention.
- **Settings "Scoresheets on this device":** every sheet with its state, the reason when the server could not place it, choosing a team and round and sending again, trying again, deleting an unsent sheet, and clearing sent ones. A sheet from another event is tagged with that event's code and never sent.
- **Cached topics:** the event, teams, tables, pods, matches, judging sessions and timetable are kept on the device, so a station opened offline shows the last schedule received.
- **Offline key login:** the device remembers each key's table from its last verified login, so a station that starts offline knows its table. When the server is back the key is verified and the outbox sends.
- **Live feed fixes:** a revoked login stops using its socket at once and recovers (log in again or show the key as rejected), and the client waits for a socket to open before writing to it.
- **Tests:** 25 Phase 4 browser checks against the release folder, with the network cut by the browser itself; every earlier suite still passes.

Changes to the plan, by decision:

- localStorage instead of IndexedDB. A device holds a day or two of its own sheets, a few kilobytes each, and synchronous storage keeps the outbox simple. IndexedDB remains an option if devices ever hold much more.
- Sheets from another event are kept and labelled on the device rather than sent and refused, so they can't be sent to the wrong event by accident.

### Phase 5: Judging

Deliverables: sessions and judging slots from import; pod timers with the official phase list; judge station; rubric form from `rubric()` definitions; rubric outbox and sync; JA dashboard; JA rubric review; JA scores page; judging queue states and judging queuer actions (reuse queue board with a judging tab); schedule display with judging.

Verify: two pods run three sessions each from iPads, one offline; JA dashboard shows phases and rubric statuses live; CV score equals 10 flagged rows plus GP per the OJS rule in tests.

#### Phase 5 status (2026-10-29)

Done and verified. Phase 5 is complete.

- **Rubrics as season data** (`tms-seasons/src/rubric.rs`): Innovation Project and Robot Design, 10 rows each with 5 Core Values rows each, using the official rubric wording; `check()` lists every row without a level and every Exceeds without a comment.
- **Judging queue:** judging slots use the same queue state machine as robot game slots. "At table" reads as "in the room". The queue board has a Judging tab; judges take teams in from the station.
- **Pod timers:** server state per pod with manual phases from the official 30-minute session plus 10 minutes for deliberation, `+1 min`, and an overtime display. Starting a session moves its team into the room.
- **Judge station** (`/judge`): the pod's current and next sessions, the timer, sessions waiting for rubrics, unscheduled rubrics, and rejected rubrics with the note.
- **Rubric form:** tabs for IP, RD and Feedback (Core Values nominations, great job and think about), live totals, a count of what still needs fixing. Rubrics go through the same device outbox as scoresheets, so a pod can judge offline.
- **Judge advisor:** dashboard with a tile per pod (phase, team, time left, rubric status) and session progress; rubric review with accept and reject; scores page.
- **Scores per the Official Judging Spreadsheet:** area ranks use RANK.EQ; a team missing an area ranks below everyone; Core Values is the CV rows plus GP on a three-match basis (average × 3, rounded); Champion's is the sum of the four ranks.
- **Event setting:** rubrics are accepted on arrival, or wait for the judge advisor (`rubric_review`).
- **Schedule display** (`/display/schedule`): robot game and judging side by side.
- **Tests:** server tests for the pod timer, sync, review and scores; unit tests for the rubric check and the score maths; 25 Phase 5 browser checks against the release folder, with one pod offline; every earlier suite still passes.

### Phase 6: Awards and deliberation

Deliverables: awards config; deliberation maths in `tms-core` with OJS-equivalence tests (area ranks with ties, missing areas, GP scaling, Champion's); deliberation page with the official allocation order and eligibility guards; advancement; finalize; awards display; exports (rankings, scores, rubrics, core values, OJS robot game CSV).

Verify: feed a past event's OJS inputs through the engine and reproduce its ranks and Champion's scores exactly; one-judged-award rule blocks a second judged award; finalize locks edits.

#### Phase 6 status (2026-10-29)

Done and verified. Phase 6 is complete.

- **Deliberation maths** (`tms-core/src/deliberation.rs`), matching the Official Judging Spreadsheet (BIOGLOW edition) formula by formula:
  - Gracious Professionalism: one to three scores add up, four are scaled by 0.75 and five by 0.6, so Core Values can be fractional (kept in hundredths). Phase 5 had averaged to a three-match basis and rounded; that was wrong and is fixed.
  - Robot game rank uses the spreadsheet's tiebreak (best, then second, third, fourth and fifth score, folded with its own weights), and a team that hasn't played ties at zero rather than ranking last.
  - Area ranks are `RANK.EQ`; a team with no accepted rubric ranks at teams + 1. Champion's score is the sum of the four ranks, and its rank is shared on ties.
  - A test transcribes the spreadsheet's formulas cell by cell over its 200-row tables and compares 3,000 random events of 1 to 40 teams. Breaking either the GP scaling or the tiebreak makes it fail.
- **Awards:** each event starts with the six required awards; the admin adds optional and local awards, sets places within the guide's limits and the ceremony order (Event setup → Awards).
- **Deliberation page** (`/judging/deliberation`): every step in the guide's order (Champion's, advancement, Robot Performance, then Core Values, Innovation Project and Robot Design place by place, Coach/Mentor, Engineering Excellence, Breakthrough, Rising All-Star, Motivate, Peer, local). Each step lists every team in the order that step goes by, with the reason a team is ineligible. The server enforces one judged award per team (Robot Performance, Coach/Mentor, Peer and local awards excepted) and the judges' selection for Breakthrough, Rising All-Star and Motivate. Giving an award to anyone but the best-ranked eligible team needs a reason, which is stored with the award and audited.
- **Advancement:** the number of advancing teams is an event setting; the judge advisor picks them in Champion's order.
- **Finalize:** locks rubrics, awards and advancement; only an admin can reopen. The page lists required places still open and the share of teams with an award (the guide aims for 30 to 50%).
- **Ceremony:** `/display/awards` shows nothing until deliberation is finalized, then one slide per award (lowest place first) and the advancing teams, revealed one at a time from the emcee page or the deliberation page, which also show the next slide to read out. The public `ceremony` topic carries only revealed slides.
- **Exports:** results and rankings, awards, robot game ranking, and the spreadsheet's input pages (robot game scores, Innovation Project, Robot Design, Core Values with GP and selections) in its column order, plus rubric feedback.
- **Also fixed:** the event form now has the rubric review setting from Phase 5.
- **Tests:** unit tests for the maths, allocation order and eligibility; server tests for awards, deliberation, finalize, the ceremony topic and exports; 26 Phase 6 browser checks against the release folder; every earlier suite still passes.

Changes to the plan, by decision:

- No separate "deliberated rank" table. Ranks never change; a choice that departs from them is recorded as the reason on the award, which is what the guide asks for.
- Coach/Mentor and Peer nominations stay on paper: the judges read the forms and the judge advisor picks the winner from the full team list.
- Local awards don't count toward the one-judged-award rule; tournaments set their own rules for them.
- The `.xlsx` fill stays in Phase 9; the CSV exports paste into the spreadsheet in the meantime.

### Phase 7: Scheduling and conflicts

Deliverables: `tms-schedule` generator with the penalty model and seedable SA; generate page with parameters, proposal preview (per-team timeline, per-table and per-pod grids), issues list, commit; manual editing (edit match time, reassign slot, swap, add match, cancel) with inline hard-constraint checks; `reschedule-team`; scoped issue service and `issues` topic shown in the TopBar and relevant pages.

Verify: generator produces zero hard issues for 6-40 teams across the manual's pod and table guidance in tests under 1 s each; editing a slot into a judging conflict is refused with the conflict shown; the issue list updates only for affected scopes (log shows no full scans).

#### Phase 7 status (2026-10-29)

Done and verified. Phase 7 is complete.

- **Schedule checks** (`tms-core/src/validation.rs`), one pure function per check, used by the generator's tests, the import and generate previews, hand edits and the live issue list:
  - errors: a team in two places at once, a match closer to the team's judging session than the event's gap, more or fewer ranking matches than rounds, no judging session, a table or pod used twice at once;
  - warnings: back-to-back matches (under 10 minutes apart), the same opponent twice, more than one judging session, a match or session during a break, ceremony or meeting.
  - Each issue's id follows from what it is about, so the same problem keeps its id across checks. A real 40-team Tournament-in-a-Box export gives one repeated-opponent warning and nothing else.
- **Generator** (`tms-schedule/src/generate.rs`): lays out practice and ranking rounds on the tables and sessions on the pods from the event's settings, skipping breaks, then places teams with seeded simulated annealing. Judging clashes are hard; back-to-back matches, repeat opponents, matches close to judging and the same table every round cost a little. If short rounds leave a team no free match (common for small events, where a round is shorter than a judging session plus its gaps), rounds gain empty matches until everyone fits. Tests cover 6 to 40 teams with the manual's pod and table guidance and a lunch break: no errors and no warnings, each under a second even in a debug build.
- **Generate page** (Event setup → Schedule): first match, first judging session and match cycle; preview with the schedule checks and every match and session; "Try another" for a new seed; save.
- **Import preview** now lists the schedule checks too.
- **Hand edits:** click a team in the matches or judging table to change who is there, swap with another slot (best swaps first, each showing whether it adds errors), or move the match or session. An edit that adds an error is refused with the reasons; "Save anyway" forces it, and the audit log records that it was forced. Staged or played matches, scored slots and started sessions can't change. Rounds are renumbered after every edit.
- **Live issues:** the server keeps each event's issues. Saving a schedule checks everything; an edit, a team change, a timetable change, or cancelling or resetting a match re-checks only the teams involved plus the event-wide checks, and pushes only what changed on the `issues` topic. The top bar shows the error count to admins, head referees and judge advisors.
- **Tests:** unit tests for each check; generator tests across sizes and seeds; server tests for generate, refused and forced edits, swap suggestions, scoped pushes and permissions; 23 Phase 7 browser checks against the release folder; every earlier suite still passes.

Changes to the plan, by decision:

- Issues are kept in memory and recomputed on start rather than stored in a table: a 40-team schedule checks in milliseconds, and nothing else needs them stored.
- "Add match" and a dedicated "reschedule team" screen are covered by assigning a team to an empty slot and by the swap suggestions.
- Exporting the schedule back to the Tournament-in-a-Box CSV moves to Phase 8 with the other printables.

### Phase 8: Printables, ops, polish

Deliverables: Typst templates and print endpoints with logos; print launcher page; systemd unit and Windows service examples for headless hosts; optional tray icon for the launcher; docs site (architecture, role guides, season authoring, ops runbook, tablet setup incl. Guided Access); display polish (TV sizes, rotation, fullscreen); performance pass (WASM size, release profile, lazy routes with `wasm-split` if needed); accessibility pass (contrast in both themes, focus order, large tap targets on iPad).

Verify: a full dry-run event day on real hardware with the printed packs; WASM bundle size recorded; restore from backup succeeds.

Visual polish asked for by Connor after Phase 3 (2026-10-29). The phases so far deliver the logic with plain screens; this is where they gain presence:

- A UI that pops more, while staying square and utilitarian: stronger hierarchy, colour, motion where it helps.
- Head referee display with lots of information at once: every table and its referee device, each team's queue state, sheet status per table, timer, what is next and what is late.
- Tablet layouts that use the screen: stations and match control show far more on an iPad than the current single-column lists.
- Scoreboard scrolling animations, schedule boards, and better-looking timers for the venue screens.
- An admin dashboard: event health at a glance (schedule progress, unscored matches, connected devices, backups, review queue).

#### Phase 8 status (2026-10-29)

Done and verified, apart from the dry run on real hardware, which needs the event's own kit.

- **Printables** (`tms-server/print/*.typ`, `src/print.rs`, `src/http/print.rs`), behind the `print` cargo feature, which is on by default:
  - team schedules (one page per team, matches, judging and timetable together), match and judging schedules, table and pod signs;
  - paper scoresheets (one page per team per match, every mission's answers to circle, built from the season so a new season needs no new template);
  - the robot game ranking, and award certificates from deliberation.
  - Templates get their data as one JSON value and share `common.typ`. Inter is built in. A page renders in a few milliseconds.
- **Print page** (`/print`, for admins, head referees and judge advisors) lists what each may print. The server checks the same roles.
- **Schedule export** to the Tournament-in-a-Box CSV. Reading it back gives the same schedule, which is checked on both real fixture files and through the API.
- **Ops:** `docs/ops.md` (release folder, services, network, backups, the day itself), `deploy/tms.service` for systemd, `docs/guides/roles.md`, `docs/guides/tablets.md` (Add to Home Screen, Guided Access), `docs/seasons.md`.
- **Visual polish:**
  - Inter ships with the client.
  - Venue screens use a dark "stage" palette whatever the device's theme.
  - The timer has large tabular digits, a progress bar with the end game marked, and table-coloured team cards.
  - The scoreboard scrolls continuously when it doesn't fit, with medal colours for the top three.
  - Each award rises into view on the ceremony screen.
  - The head referee gets a field view: every table's device, the team on it and its queue state, the next team, and whether the last sheet has arrived. A pace badge says how far behind the robot game is.
  - Admins get an event health dashboard on Home: robot game and judging progress, pace, scoresheets waiting, devices connected, schedule errors.
  - Stations show the team in large type, and below 1024 px the side menu becomes a strip along the top, so portrait tablets get the full width.
- **Sizes:**
  - client: 2.8 MB of WASM, 714 KB with brotli;
  - program: 142 MB, of which Typst adds about 50 MB. Stripping symbols would take it to 117 MB.
- **Tests:** server tests render every printable and check who may print it, and that the schedule export imports again; 12 Phase 8 browser checks (downloads, dashboard, stage screens, font); every earlier suite still passes.

Not done, by decision:

- A tray icon and a Windows service wrapper: the launcher window and NSSM cover both. The ops guide says how.
- Lazy-loaded routes (`wasm-split`): at 714 KB compressed the client loads quickly on event Wi-Fi.
- A dry run on real hardware with printed packs: for Connor's team before the first event.

#### After Phase 8: one screen per device (2026-10-30)

- The side menu is gone. A slim top bar (Menu, event, clock, connection) leaves the page the full width; Menu slides out with the screens this login may open, Settings, the venue screens, theme, full screen and Log out.
- A login with a single job opens straight to it (`Route::primary`), and Home sends it there too; admins and multi-role logins keep Home.
- Venue screens are linked from the login page and listed at `/display`, so they can be found without knowing the addresses.
- Browser suites go through the menu (`go`, `menu` in `e2e/lib.mjs`); phase 3's judging-clash check no longer depends on the time of day.

#### After Phase 8: visual pass (2026-10-30)

- Design system (`tms-ui`): 8 px controls and 12 px panels with a soft shadow; badges are sentence-case pills with a dot; card titles are plain headings; inputs get a focus ring; a `Tabs` control replaces rows of buttons used as tabs; `DangerGhost` buttons for destructive actions repeated down a list; dialogs pop in.
- Match control: the timer is a dark stage panel beside a card per staged team (table colour, team number, queue progress, actions). The match list marks the next match, tints staged and running ones, dims finished ones, and keeps Cancel quiet.
- Referee station: the team on the table fills a hero under a band in the table's colour, with a five-step queue progress and large actions; matches to score are their own call-outs.
- Scoresheets and rubrics: answers are segmented controls, points show as pills, and the form header stays under the top bar.
- Judge station: Inter clock; the phase list strikes through finished phases.

#### After Phase 8: event-day walkthrough (2026-10-30)

Each role was walked through a simulated event (40 teams, six tables, ten pods, TVs per table pair, queuers on tablets and phones, a Windows laptop running the server). What changed:

- **Queueing:** `queue_soon_minutes` (20) joins `queue_call_minutes` (now 10 by default). Teams are Soon, Queue now, or Late (from half the Queue now window) automatically; the manual states stay. The queue board is team cards with one next-step button, the device remembers its table pair, a count strip, late teams first, and Later as a plain list. Judging has the same cards.
- **Venue screens:** `/display/timer?tables=Red,Blue` and `/display/queue?tables=…` show one pair. While another pair's match runs the timer shows that pair's next match instead of a clock, and plays no sounds. `/display` links each pair. The pits screen lists only teams still to reach the queue.
- **Head referee:** the timer panel offers the next match to stage. Scoresheet review has tabs with counts and a link back.
- **Referee:** the team to score comes before the next match; one big button for the next step.
- **Announcer:** "Read this out" words the field and the next match as sentences; the top 10 waits for scores.
- **Judge advisor:** a count strip, the next session to start, and pod tiles with session dots, device state and a Not started warning.
- **Wi-Fi gaps:** queue changes from any tablet retry for two minutes while there is no connection.
- **Access keys:** QR codes are login links (`/login?access=…`); keys for every table and pod at once, as printable cards.
- **Windows host:** the server keeps the laptop awake while it runs; the launcher and ops guide explain the firewall prompt (tick Public networks) and the lid.
- Scenarios: `e2e/day.mjs` (screenshots of every role), `pairs.mjs`, `flaky.mjs`, `keycards.mjs`.

#### After Phase 8: the event admin (2026-10-30)

- **Admin login:** the first start creates `admin` with the password `admin`, with no forced change. The launcher's Server tab sets the admin password at any start (creating or re-enabling `admin`), the same as `--admin-password`. Users can be created or reset with a password the admin chooses (`password` on `POST /users` and `/users/{id}/reset-password`); launcher Maintenance can set one too. Settings has a password change. The launcher's Copy buttons work (eframe's `clipboard` feature was off).
- **Admin overview (Home):** event health, robot game now, missing scoresheets, the field, station devices, announcements; the screens list is compact.
- **Missing scoresheets** (Home and Match control): each with what its table's tablet holds, Enter sheet (a paper sheet, as the head referee or admin) and Mark no show with a reason. A no-show after the match is allowed for the head referee, and undone from the match row.
- **Device status:** station devices report the sheets and rubrics they hold (`DeviceStatus` message, `Presence.waiting`), shown on the field, station and pod tiles.
- **Bug fixed:** the outbox tagged documents with `kind`, which a scoresheet also has, so kept sheets could not be read back after a reload and were silently dropped. The tag is now `document`, unreadable storage is set aside, and a client test covers it.
- Scenarios: `e2e/admin.mjs`; `flaky.mjs` now also closes and reopens a tablet holding a sheet.

### Phase 9: Later

Native client builds of `tms-client` (Dioxus Android, iOS and desktop) using the same REST, WebSocket and JWT; installable offline web app (service worker and manifest) for HTTPS events; past seasons (UNEARTHED, SUBMERGED, MASTERPIECE) ported; BIOGLOW Future Edition season module; multi-event switching UI; OJS `.xlsx` fill via `rust_xlsxwriter`; optional camera QR key scan; Playwright end-to-end suite; optional Postgres `LISTEN/NOTIFY` if a second server process is ever needed.

## 19. Decisions for Connor

Defaults are what the plan assumes; say so if you want the other option.

1. Styling: Tailwind v4 utilities over CSS variables (default) vs hand-written scoped CSS.
2. HTTPS and offline install: decided. Web client over HTTP or HTTPS. Installable offline web app deferred. Native clients later (ADR-5).
3. Login tokens: decided. JWT with an in-memory revocation list (ADR-7).
4. Scoresheet review mode default: decided. AutoPublish, with HR flags for duplicates and edits. Configurable per event.
5. GP comment when not Accomplished: decided. Required, as an event setting that defaults on.
6. Printables: Typst on the server (default) vs print CSS only.
7. Launcher: decided. An egui window that supervises `tms --headless` as a child process, with `--headless`/`--no-gui` for terminal use (ADR-14, section 17.1).
8. Queue actions offline: not supported (default, server owns queue state) vs outbox for queue actions too.
9. Future Edition support this season: no (default).
10. Rubric model: one accepted rubric per team by the head judge (default, matches Event Hub) vs one per judge with averaging.
11. Font choice and primary colour: Inter + teal `#009485` carried over (default).
12. Database: decided. Embedded PostgreSQL by default, `--database-url` for an external server (ADR-13).
13. Release platforms: decided. Windows, macOS and Linux server builds, each packaged as one `tms` binary with the embedded PostgreSQL and web client (per-platform builds, because the PostgreSQL bundle is per platform).
14. Default ports: 8080 for HTTP and 8443 for HTTPS (default) vs 80/443. The standard ports need administrator rights on Linux and macOS.

## 20. References

Official FLL (BIOGLOW, 2026-27), base `https://firstinspires.blob.core.windows.net/fll/challenge/2026-27/`:
`fll-challenge-bioglow-rgr.pdf` (rulebook), `fll-challenge-bioglow-updates.pdf`, `fll-challenge-bioglow-software-scoresheet.pdf`, `fll-challenge-bioglow-excel-scorer.xlsm`, `fll-challenge-bioglow-rubrics-color.pdf`, `fll-challenge-bioglow-judging-session-flowchart.pdf`, `fll-challenge-bioglow-judging-session-script-questions.pdf`, `fll-challenge-bioglow-awards-and-allocation.pdf`, `fll-challenge-bioglow-official-judging-spreadsheet.xlsx`, `fll-challenge-bioglow-tournament-manual.pdf` (serves the Sept 2024 revision). Volunteer roles: `https://firstinspires.blob.core.windows.net/fll/challenge/volunteer-role-descriptions.pdf`. Season page: `https://www.firstinspires.org/programs/fll/game-and-season`.

FIRST Australia: TD page `https://www.firstaustralia.org/tournament-directors/fll-challenge`; Tournament-in-a-Box source `https://github.com/first-australia/tournament-in-a-box` (scheduler and CSV export); Dashboard `https://firstaustralia.systems`.

Other systems for comparison: LEMS (FIRST Israel) `https://github.com/FIRSTIsrael/lems`; FLLScorer `https://tools-for-fll.github.io/FLLScorer/`; fll-sw `https://jpschewe.github.io/fll-sw/`; Lumieos schedule CSV `https://lumieos-documentation.pages.dev/administration/events-management/schedule-csv-format`.

Rust and Dioxus: Dioxus 0.7 docs `https://dioxuslabs.com/learn/0.7/` (signals, resources, router, PWA example at `examples/10-integrations/pwa`, optimising guide, Tailwind guide); axum chat example `https://github.com/tokio-rs/axum/tree/main/examples/chat`; tower-http `ServeDir`; sqlx 0.9 changelog and CLI README; WebKit storage policy `https://webkit.org/blog/14403/updates-to-storage-policy/`; typst-as-lib `https://github.com/Relacibo/typst-as-lib`; serialization benchmarks `https://github.com/djkoloski/rust_serialization_benchmark`.

Legacy files worth opening when porting: `tms_infra/src/infra/fll_infra/seasons/fll_2026.rs` (BIOGLOW questions), `tms_schedule_handler/src/v1/` and `docs/guides/schedule.md` (CSV format), `tms_server/src/services/match_service/timer_sub_service.rs` (timer phases), `tms_server/src/database/extensions/team_extensions.rs` (ranking, to be corrected to best/2nd/3rd competition ranking), `tms_server/src/services/integrity_check_service.rs` and `tournament_integrity_checks/` (E/W catalogue), `tms_client/assets/` (mission images, audio, LCD font), `docs/roles/*.md`.

---

## Appendix A: BIOGLOW (Founders Edition) robot game scoring summary

| Mission | Fields | Points |
|---|---|---|
| Equipment Inspection | fits one launch area under 305 mm: bool | 20 |
| Precision Tokens | remaining 0-6 | 0 / 10 / 15 / 25 / 35 / 50 / 50 |
| M01 Drone Survey | drone off mat: bool; bonus LiDAR map flipped with marker in area: bool (requires drone) | 20; +10 |
| M02 Exploding Seeds | seeds off stalk 0-3 | 10 each |
| M03 Flip the Rock | flag down: bool; bonus rock returned: bool (requires flag) | 20; +10 |
| M04 Lucky Leaves | leaves off nest 0-2; katydid at least partly in habitat: bool; bonus original position: bool (requires katydid in habitat) | 10 if ≥1 leaf and katydid in; +20 if 2 leaves and bonus; 0 if katydid out. Two leaves without the bonus is a valid 10 |
| M05 Reaching Roots | root: none / partial / complete | 0 / 10 / 20 |
| M06 Leafcutter Frenzy | ant touching nest: bool; fragments in nest 0-4 | 10 per fragment only if ant touching |
| M07 Humongous Fungus | mycelium extended: bool; bonus connections to opponent's root 0-2 | 20; +10 each |
| M08 Tangled | vine touching mat: bool | 30 |
| M09 Research Platform | platform raised; camera trap deployed; seed off tree: 3 bools | 10 each |
| M10 Fragile Microhabitats | spider habitat original; snail habitat original: 2 bools | 10 each |
| M11 Window to the Past | root cover down: bool | 20 |
| M12 Forest Elder | cane raised touching tree: bool; support tie around post: bool | 20; 10 |
| M13 Keystone Species | keystone on platform and trees raised: bool | 30 |
| M14 Seeds of Renewal | seeds in station 0-4; bonus touching mat 0-4 (capped at seeds in station) | 5 each; +5 each |
| M15 Biocentric Architecture | canopy raised; skylight in; hatch open: 3 bools; dock: Mine / City / Farm, no default (the referee must choose) | 10 each; +10 if the dock's element is done (Mine: canopy, City: skylight, Farm: hatch) |
| GP | 2 / 3 / 4 | not in robot score |

Theoretical maximum 530. Checked in Phase 2: `tms-seasons` transcribes the official Excel scorer's formulas cell by cell as a test oracle and agrees on 20,000 random sheets. Legacy `fll_2026.rs` was wrong in two places: it flagged two leaves without the katydid bonus as an error, and it had a "None" dock option. The Challenge Updates document (updated 14 Oct 2026) is binding.

## Appendix B: Rubric rows (BIOGLOW, same structure since 2024-25)

Innovation Project (CV-flagged marked ★): Identify – Define; Identify – Research ★; Design – Plan; Design – Teamwork ★; Create – Innovation ★; Create – Model; Iterate – Sharing; Iterate – Improvement; Communicate – Impact ★; Communicate – Fun ★.

Robot Design (★ = CV): Identify – Strategy; Identify – Research ★; Design – Ideas ★; Design – Building/Coding; Create – Attachments; Create – Code/Sensors; Iterate – Testing; Iterate – Improvements ★; Communicate – Impact ★; Communicate – Fun ★.

Each row: Beginning 1 / Developing 2 / Accomplished 3 / Exceeds 4 (comment required at 4). Feedback page: "Great job" and "Think about" for Core Values, Innovation Project, Robot Design; nominations for Breakthrough, Rising All-Star, Motivate.

## Appendix C: Tournament-in-a-Box CSV, Version 1

```
Version Number,1
Block Format,1
Number of Teams,N
<team_number>,<name>,<affiliation>,
Block Format,2
Number of Ranking Matches,M
Number of Tables,T
Number of Teams per Table,2
Number of Simultaneous Tables,S
Table Names,<t1>,<t2>,...
<match#>,<start HH:MM:SS AM/PM>,<end>,<team for t1>,<team for t2>,...   (blank = table unused)
Block Format,3
Number of Judged Events,1
Number of Event Time Slots,K
Number of Judging Teams,P
Event Name,<name>
Room Names,<r1>,<r2>,...
<session#>,<start>,<end>,<team for r1>,...
Block Format,4            (optional practice matches, same shape as block 2 with "Number of Practice Matches")
```

Times may be prefixed with a day label; Legacy used it as a sub-category. Parse with the `csv` crate, honour AM/PM, attach the event date, and number practice and ranking matches in separate rounds.

## Appendix D: Glossary

- Slot: one team at one table in one match, or one team in one pod in one session.
- Staged: a match loaded onto the timer by the head referee (Legacy "loaded").
- Station: the per-device page for a referee (table) or judge (pod).
- Outbox: the device-local queue of scoresheets and rubrics waiting to sync.
- Access key: an event-scoped credential with a role prefix, used by shared devices and for offline login.
- Area: one of Innovation Project, Robot Design, Core Values, Robot Game, each producing a rank.
- Champion's score: the sum of the four area ranks; lowest wins.
