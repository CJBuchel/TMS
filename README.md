# TMS

Tournament management for FIRST LEGO League Challenge: robot game, integrated queueing, judging, deliberation and
printables. A release is one folder: the `tms` program with PostgreSQL built in, and the web client in `web/`.
Every device uses it from a browser.

- Design and phased plan: [PLAN.md](PLAN.md)
- Running and testing locally: [docs/development.md](docs/development.md)
- API: [REST](docs/api/rest.md) and [live feed](docs/api/websocket.md)

## Running it

Unzip the release and run the program inside the folder; it finds `web/` and creates `data/` next to itself.
Double-clicking `tms` opens the launcher window: press Start, and scan the QR code from a tablet.

```bash
./tms                         # the launcher window
./tms --headless              # no window: http://<this machine>:8080, QR code printed in the terminal
./tms --help                  # every setting; each is also a TMS_* variable or a tms.toml key
```

The first start creates the user `admin` with the password `admin`; set your own in the launcher's Server tab or with `--admin-password`.

## Status

- Phase 0 (foundations): done.
  - login with a password or an access key, which also works offline
  - JWT tokens that can be revoked instantly
  - the live feed with declarative subscriptions
  - the app shell with light and dark themes
- Phase 0b (one release folder): done.
  - embedded PostgreSQL; the web client ships as a folder beside the program
  - flags only
  - HTTPS with an HTTP redirect
  - Linux, Windows and macOS builds in CI
- Phase 1 (event setup): done.
  - teams, tables, pods, users, access keys bound to a table or pod, audit log
  - Tournament-in-a-Box schedule import with a preview
- Phase 2 (robot game): done.
  - BIOGLOW scoring checked against the official Excel scorer
  - match control and timer, referee station and scoresheet form, head referee review
  - ranking, timer and scoreboard displays with sounds, emcee page
- Phase 3 (integrated queueing): done.
  - queue board, referee readiness, a start that waits for the teams, station presence, queue display
- Phase 3b (launcher window and backups): done.
  - start, stop and watch the server; QR code; settings; backups and restore; logs; password recovery
- Phase 4 (offline): done.
  - scoresheets saved on the device first and sent when possible, binding and retry, cached schedule, offline key login
- Phase 5 (judging): done.
  - judge station with pod timer and official phases, rubric form from the official wording, saved on the device first
  - judge advisor dashboard, rubric review, scores and ranks per the Official Judging Spreadsheet
  - judging tab on the queue board, schedule display
- Phase 6 (awards and deliberation): done.
  - scores and ranks exactly as the Official Judging Spreadsheet computes them, checked against its formulas
  - awards per event, deliberation in the official allocation order with the one-judged-award rule, advancement
  - finalize, the awards ceremony on the venue screen run from the emcee page, CSV exports for the spreadsheet
- Phase 7 (scheduling and conflicts): done.
  - schedule generator for 6 to 40 teams, previewed before saving, avoiding breaks and judging clashes
  - schedule checks shared by the generator, the import preview, hand edits and a live issue count
  - hand edits: change a slot's team, swap slots (with suggestions), move a match or session; conflicts refused unless forced
- Phase 8 (printables, ops, polish): done.
  - PDFs: team schedules, match and judging schedules, signs, paper scoresheets, ranking, certificates
  - schedule export to Tournament-in-a-Box CSV; ops runbook, role and tablet guides, systemd unit
  - venue screens on a dark stage look, field view for the head referee, event health for admins, Inter everywhere
