# Running TMS

## The release folder

Unzip the release anywhere. It holds:

- `tms` (`tms.exe` on Windows): the server, with PostgreSQL built in.
- `web/`: the web client the server hands to browsers.
- `README.txt`.

On first start TMS creates `data/` next to the program. It holds the database, the configuration (`tms.toml`), logs and backups. Copying the whole folder, with TMS stopped, copies the event.

## Starting

Double-click `tms`. The launcher window starts the server and shows:

- the address and QR code other devices use;
- the logs;
- backups, with restore;
- maintenance: resetting a user's password and deleting an event.

The first start creates the user `admin` with the password `admin`. Type your own in the launcher's Server tab (Admin password) before starting, or any later time: starting with a password there gives `admin` that password and re-enables it, so the launcher is always the way back in. In the web UI, add a user for yourself (Event setup → Users, with a password you choose) and keep `admin` for recovery.

On a machine without a desktop, run `tms --headless`. It prints the same address and QR code in the terminal; `--admin-password` (or `TMS_ADMIN_PASSWORD`) sets the admin password at start. `tms --help` lists every flag; each has a `TMS_…` environment variable too.

## Running as a service

- **Linux:** `deploy/tms.service` is a systemd unit. Its comments give the steps. Set `TMS_ADMIN_PASSWORD` in the unit to choose the admin password.
- **Windows:** run `tms.exe --headless --no-qr` as a service with a service wrapper such as NSSM (`nssm install TMS C:\tms\tms.exe --headless --no-qr`). Alternatively, use a Task Scheduler task set to run at startup, whether or not a user is logged in. Stopping the service must send Ctrl+C or close the console, not kill the process, so the database shuts down cleanly. NSSM does this by default.

## Network

Devices reach TMS at `http://<this machine>:8080`, or the port given with `--port`.

- Allow that port through the machine's firewall. On Windows, the first start asks whether to allow `tms`: tick **Public networks** as well as Private, because school Wi-Fi usually counts as public. If you missed it, open Windows Security → Firewall & network protection → Allow an app through firewall, and tick both boxes for `tms`.
- Use a wired connection for the server if you can.
- One Wi-Fi network just for the event, without client isolation, saves a lot of trouble.

For HTTPS, give a certificate and key with `--tls-cert` and `--tls-key`. The HTTP port then redirects to HTTPS on `--tls-port` (8443 by default). Tablets accept the certificate only if they trust its issuer.

## Backups

- TMS backs up every 10 minutes (`--backup-interval`) and keeps the last 20 (`--backup-retain`). Manual backups are always kept.
- Backups are `.tmsbackup` files in `data/backups`. Each one holds the whole database, not just one event.
- The launcher's Backups page creates a backup now, imports a backup file from elsewhere, and restores one. A restore backs up the current data first.

Before the event, practise a restore on a spare laptop: copy a backup across, import it, restore it, and check that the schedule and scores are there.

## On the day

- Keep the server laptop on mains power. While the server runs, TMS stops Windows from going to sleep by itself (the screen may still turn off), but closing the lid still follows the power settings: set "When I close the lid" to "Do nothing", or keep it open.
- Each TV or projector opens `http://<this machine>:8080/display` and picks its screen. A TV beside a pair of tables can show just that pair's timer or queue: then teams there only see a clock while their own match runs.
- Queuers' tablets remember their table pair. Teams show as Soon, then Queue now, then Late, from the times under Event setup → Event → Queueing.
- The launcher's QR code takes a device straight to TMS.
- Station tablets log in with access keys (Event setup → Access keys). A key binds the tablet to its table or pod. Revoking a key logs that tablet out at once.
- If the server stops, tablets keep scoresheets and rubrics on the device and send them when it is back.
- If Wi-Fi drops, the same happens. The device's Settings page shows anything still waiting.
- A forgotten password is reset from the launcher's Maintenance page, or by an admin on the Users page.

## Printing

The Print page (admins, head referees, judge advisors) makes PDFs:

- team schedules for check-in packs, and the match and judging schedules;
- table and pod signs;
- paper scoresheets for when a tablet isn't available;
- the robot game ranking;
- award certificates.

Print again after the schedule changes.
