# REST API

Base path `/api/v1`. JSON bodies. Authenticated calls send `Authorization: Bearer <token>`, where the token comes from a login.
JSON Schemas for request and response bodies are in [`schemas/`](schemas/).

Errors always have the same shape, with a stable machine-readable `code`:

```json
{"code":"auth.invalid_credentials","message":"invalid credentials"}
```

| Status | Typical codes |
|---|---|
| 400 | `event.invalid`, `event.invalid_dates`, `event.invalid_timezone`, `key.invalid`, `banner.invalid`, `auth.password_too_short` |
| 401 | `auth.required`, `auth.invalid_credentials` |
| 403 | `auth.forbidden`, `auth.password_change_required` |
| 404 | `not_found` |
| 409 | `conflict.duplicate` |
| 429 | `auth.rate_limited` |

## Login tokens

Tokens are HS256-signed JWTs. Each one carries the user or access key it belongs to, its roles, and an expiry. A login with a password lasts 12 hours; a login with an access key lasts 24 hours, or until the key itself expires if that is sooner. Call `POST /auth/refresh` before expiry to get a new token; the web client does this automatically when less than 6 hours remain.

Ending a login takes effect immediately, even though the token is still signed:

- `POST /auth/logout` ends that one token.
- Changing a password ends every older token for that user, on every device.
- Revoking an access key ends every token issued for it.

Live WebSocket connections using an ended token receive `auth.revoked` and are closed.

After 10 failed logins from one address within 5 minutes, further password and key logins from that address get 429 until the window passes.

## Endpoints

| Method and path | Role | Purpose |
|---|---|---|
| `GET /version` | public | Server version and WebSocket protocol version |
| `GET /healthz` (no `/api/v1` prefix) | public | 200 when the database answers |
| `POST /auth/login` | public | `{username, password}` → `{token, expires_at, identity}` |
| `POST /auth/key` | public | `{key}` → same shape; key text is case- and space-insensitive |
| `POST /auth/refresh` | any | A new token with current roles |
| `POST /auth/logout` | any | Ends the calling token |
| `GET /auth/me` | any | The caller's identity and roles |
| `POST /auth/password` | user | `{current_password, new_password}` → a new token; clears a forced password change |
| `GET /events` | admin | All events |
| `POST /events` | admin | Create: `{code, name, season_id, timezone, starts_on, ends_on}` |
| `GET /events/active` | public | The active event or `null` |
| `POST /events/{id}/activate` | admin | Make this the one active event |
| `GET /events/{id}/keys` | admin | Access keys for an event (never the key text) |
| `POST /events/{id}/keys` | admin | `{label, role, expires_at?}` → the key text, returned once |
| `POST /keys/{id}/revoke` | admin | Revokes a key and every login made with it |
| `GET /events/{id}/banners` | display | Active banners |
| `POST /events/{id}/banners` | admin | `{severity, message}` |
| `POST /banners/{id}/clear` | admin | Deactivate a banner |
| `GET /seasons` | public | Seasons an event can use |
| `PATCH /events/{id}` | admin | Name, season, timezone, dates and `settings` (match length, rounds, review mode, judging times) |
| `POST /events/{id}/archive` | admin | Ends the event and revokes its access keys |
| `GET/POST /events/{id}/teams`, `PATCH/DELETE /teams/{id}` | display / admin | Teams; deleting a scheduled team is refused (409 `conflict.in_use`) |
| `GET/POST /events/{id}/tables`, `POST /events/{id}/tables/order`, `PATCH/DELETE /tables/{id}` | display / admin | Competition tables and their order |
| `GET/POST /events/{id}/pods`, `POST /events/{id}/pods/order`, `PATCH/DELETE /pods/{id}` | display / admin | Judging pods and their order |
| `GET /events/{id}/matches`, `GET /events/{id}/judging-sessions` | display | The schedule, with slots |
| `POST /events/{id}/import/tiab[?commit=true]` | admin | Body: Tournament-in-a-Box CSV. Without `commit` returns a preview and changes nothing; with it, replaces the schedule. Bad files get 422 `import.invalid` with every problem in `details` |
| `GET/POST /events/{id}/blocks`, `PATCH/DELETE /blocks/{id}` | display / admin | Timetable blocks; times are sent as event-local `starts_local`/`ends_local` |
| `POST /events/{id}/schedule/generate[?commit=true]` | admin | `{match_start_local, judging_start_local, match_cycle_minutes, seed}` → `{preview, matches, sessions}`. Builds matches and judging sessions for every team on the event's tables and pods from the robot game and judging settings, keeping clear of breaks on the timetable. Without `commit` nothing changes; the same request and seed give the same schedule |
| `GET /events/{id}/schedule/issues` | head referee, judge advisor | What the schedule checks find (`code`, `severity` `error` or `warning`, `team_id`, `refs`, `message`) |
| `POST /match-slots/{id}/assign`, `POST /judging-slots/{id}/assign` | admin | `{team_id or null, force?}`. Changes who is in the slot. 422 `schedule.conflict` with each new error in `details` unless forced; 409 `match.invalid_state` once a match is staged or played, `slot.scored` when it has a scoresheet, `slot.started` once a judging session started. Answers with the touched teams' issues |
| `POST /match-slots/swap`, `POST /judging-slots/swap` | admin | `{a, b, force?}`. Swaps two slots' teams, with the same checks |
| `GET /match-slots/{id}/swaps` | admin | Every slot this one could swap with, best first: no new errors, then fewest added warnings |
| `POST /matches/{id}/move`, `POST /judging-sessions/{id}/move` | admin | `{start_local, force?}`. Moves a match or session, keeping its length, with the same checks |
| `GET /events/{id}/print/{name}.pdf` | admin; head referee for `scoresheets` and `rankings`; judge advisor for `certificates` | `team-schedules`, `match-schedule`, `judging-schedule`, `table-signs`, `pod-signs`, `scoresheets`, `rankings`, `certificates` |
| `GET /events/{id}/schedule/export.csv` | admin | The schedule as a Tournament-in-a-Box CSV; importing it again gives the same schedule |
| `GET/POST /users`, `PATCH /users/{id}`, `POST /users/{id}/reset-password` | admin | Users. Creating or resetting takes an optional `password` the admin chooses; without one the user gets a one-time password to change at first login |
| `GET /audit?event_id=&entity_type=&before=&limit=` | admin | The audit log, newest first |
| `POST /matches/{id}/stage` | head referee | Puts a match on deck. Body optional: `{force, reason}`. 409 `match.table_in_use` if another staged match uses its tables; 409 `match.unscored_tables` if an earlier match on its tables still needs a scoresheet, unless forced with a reason |
| `POST /matches/{id}/unstage`, `/cancel`, `/reset` | head referee | Back to scheduled; cancel (not while running); reset a finished or cancelled match to replay it. 409 `match.invalid_state` otherwise |
| `GET /events/{id}/timer` | display | The match timer |
| `POST /events/{id}/timer/start` | head referee, emcee | Runs every staged match. Body optional: `{countdown, force, reason}`. 409 `timer.running`, `timer.nothing_staged`, or `timer.not_ready` while a team is not ready, a no-show or scratched (when the event asks for it). `force` with a reason starts anyway; head referee only |
| `POST /events/{id}/timer/abort` | head referee | Stops the run; its matches go back to staged |
| `POST /events/{id}/timer/end` | head referee | Ends the run now; its matches finish |
| `GET /events/{id}/rankings` | display | Robot game ranking: best, then second, then third score |
| `POST /sync/scoresheets` | referee | `{documents: [ScoresheetDoc]}`, up to 50 → `{results: [{id, outcome, ...}]}` with outcome `accepted`, `duplicate`, `needs_binding` or `rejected`. Sending a sheet again is harmless |
| `GET /events/{id}/scoresheets`, `GET /scoresheets/{id}` | referee | Stored scoresheets |
| `POST /scoresheets/{id}/accept`, `/unpublish` | head referee | Publish (supersedes the round's earlier sheet) or take back to review |
| `POST /scoresheets/{id}/reject` | head referee | `{note}`, required; the referee sees it |
| `POST /judging-slots/{id}/queue` | queuer, judge, judge advisor | Same body as a match slot. Queuers call and send teams; judges take them into the room (`at_table`); either can mark a no-show; undoing a no-show is for the judge advisor |
| `GET /events/{id}/pod-timers` | display | One timer per pod: session, phase, when the phase ends |
| `POST /pods/{id}/timer/{action}` | judge | `start` (body `{session_id}`), `next`, `previous`, `extend` (one more minute) or `finish`. Starting moves the team into the room. 409 `pod_timer.invalid` for an impossible step |
| `POST /sync/rubrics` | judge | `{documents: [RubricDoc]}`, up to 50 → `{results: [{id, outcome, ...}]}`, as for scoresheets. Incomplete rubrics (a row without a level, an Exceeds without a comment) are `rejected` with the reason |
| `GET /events/{id}/rubrics`, `GET /rubrics/{id}` | judge | Stored rubrics |
| `POST /rubrics/{id}/accept` | judge advisor | Accept; supersedes the team's earlier accepted rubrics |
| `POST /rubrics/{id}/reject` | judge advisor | `{note}`, required; the pod sees it |
| `GET /events/{id}/judging-scores` | judge advisor | Per team: IP, RD and Core Values scores, robot game best score, the four area ranks and the Champion's sum of ranks |
| `GET /events/{id}/awards` | display | The awards the event presents, in ceremony order |
| `POST /events/{id}/awards` | admin | `{kind, name?, places}`. Kinds: `champions`, `core_values`, `innovation_project`, `robot_design`, `robot_performance`, `coach_mentor` (required, created with every event), `engineering_excellence`, `breakthrough`, `rising_all_star`, `motivate`, `peer`, `local` (name required, any number). 409 `award.exists`; 400 `award.places` past the guide's limit |
| `PATCH /awards/{id}`, `DELETE /awards/{id}`, `POST /events/{id}/awards/order` | admin | Rename or change places (not below a place that has a winner); remove an optional award without winners (409 `award.required`, `award.has_winners`); set the ceremony order |
| `GET /events/{id}/deliberation` | judge advisor | Scores and ranks per the Official Judging Spreadsheet, judges' selections from accepted rubrics, awards, winners, advancement, and whether it is finalized |
| `POST /awards/{id}/winners` | judge advisor | `{team_id, place, note?}`. 409 `award.place_taken`, `award.ineligible` (one judged award per team; Breakthrough, Rising All-Star and Motivate need the judges' selection); 400 `award.note_required` when skipping the best-ranked eligible team without a reason |
| `DELETE /awards/{id}/winners/{place}` | judge advisor | Opens the place again |
| `POST /events/{id}/advancement` | judge advisor | `{team_ids}` in order, at most the event's `advancement_slots` |
| `POST /events/{id}/deliberation/finalize` | judge advisor | Locks rubrics (sync answers `rubric.finalized`, review answers 409), awards and advancement, and lets the ceremony start. Changes after it get 409 `deliberation.finalized` |
| `POST /events/{id}/deliberation/reopen` | admin | Unlocks; the ceremony starts over |
| `GET /events/{id}/ceremony/script` | emcee, judge advisor | Every ceremony slide, revealed or not |
| `POST /events/{id}/ceremony/{next\|previous\|restart}` | emcee, judge advisor | Moves the venue screen. 409 `ceremony.not_finalized` before finalizing |
| `GET /events/{id}/exports/{name}.csv` | judge advisor | `results`, `rankings`, `innovation-project`, `robot-design`, `core-values`, `robot-game`, `rubrics`, `awards`. The judging ones keep the Official Judging Spreadsheet's input columns |
| `POST /slots/{id}/queue` | queuer, referee, head referee | `{action, note?}` with action `call`, `on_way`, `wait`, `at_table`, `ready`, `no_show`, `scratch` or `undo` → the slot's match. Queuers call and send teams; referees take them at the table and mark them ready; either can mark a no-show; scratching and undoing a no-show are for the head referee. 403 for the wrong role, 409 `queue.invalid_state` for an impossible step |

Roles inherit: admin satisfies every role, head referee satisfies referee and queuer, judge advisor satisfies judge, and every role satisfies display.
