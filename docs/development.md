# Development

Everything is embedded: the server brings its own PostgreSQL, and the tests start their own. No Docker and no
separate database install.

## Tools

```bash
rustup target add wasm32-unknown-unknown
cargo install dioxus-cli --version 0.7.10 --locked
cargo install sqlx-cli --version ^0.9 --no-default-features --features postgres,rustls --locked   # only to change SQL
```

The first build downloads a PostgreSQL 17 archive from GitHub (cached in `~/.theseus`). The version is pinned in
`.cargo/config.toml`.

## Layout

| Path | What |
|---|---|
| `crates/tms-core` | Shared types: roles, access-key format, topics, WebSocket messages, REST bodies. No IO; compiles to WASM. |
| `crates/tms-db` | Where the database comes from: embedded PostgreSQL (bundled, run as a child process) or an external URL. Pool and migrations. |
| `crates/tms-server` | axum library: REST under `/api/v1`, live feed at `/ws`, the web client from its folder, HTTPS with an HTTP redirect. |
| `crates/tms-launcher` | The `tms` program: flags, `tms.toml`, logging, join URLs and QR code. The launcher window comes in Phase 3b. |
| `crates/tms-ui` | Design-system components (Button, Badge, Card, TextField, Select, Banner, Modal, DataTable). |
| `crates/tms-client` | Dioxus web app. `tailwind.css` holds the theme tokens; dx generates `assets/tailwind.css` from it. |
| `migrations/` | The database schema as plain SQL, compiled into the program and applied at start. |
| `.sqlx/` | Offline query data so builds need no database. Regenerate after changing SQL. |
| `docs/` | This site (Material for MkDocs). `docs/api/schemas/` is rewritten by `cargo test`. |

## Run it

```bash
dx build --package tms-client --platform web          # client into target/dx/tms-client/debug/web/public
cargo run -p tms-launcher -- --data-dir ./dev-data    # http://localhost:8080
```

The server serves the client from `web/` next to the program. A debug build has none there, so it uses the
`dx build` output above; run `dx build` again after client changes. Without a client, pages explain how to
build one, and the API works regardless.

The first start creates the user `admin` with the password `admin`; `--admin-password` sets another at any start. `./dev-data` holds the database, logs and an optional `tms.toml`; delete it to start fresh. Without
`--data-dir`, a debug build keeps its data in `target/debug/data`, which `cargo clean` deletes.

For client hot reload, keep that running and in a second terminal:

```bash
dx serve --package tms-client --platform web --port 8081   # http://localhost:8081; proxies /api and /ws to :8080
```

Printable PDFs use Typst, which is the slowest part of a fresh build. For quicker builds while working on
something else, leave it out; the Print page then says this build can't print:

```bash
cargo run -p tms-launcher --no-default-features -- --data-dir ./dev-data
```

Templates are in `crates/tms-server/print/` (`common.typ` holds the shared look). Each reads one JSON value; see
`src/http/print.rs` for what each gets.

To look at the database with pgAdmin, DBeaver or `psql`, give it a fixed port:

```bash
cargo run -p tms-launcher -- --data-dir ./dev-data --db-port 55432
# user postgres, database tms, password in ./dev-data/postgres/password
```

## Changing SQL

Queries are checked at build time against `.sqlx/`. After adding or changing a query or a migration, run the
server with a fixed database port as above, then:

```bash
DATABASE_URL=postgres://postgres:$(cat dev-data/postgres/password)@localhost:55432/tms \
  cargo sqlx prepare --workspace -- --all-targets
```

A query missing from `.sqlx/` fails the build, so CI catches a forgotten prepare.

## Release

```bash
scripts/release.sh            # dist/tms-<version>-<os>-<arch>/ and the same as a .zip
```

The folder holds the `tms` program (PostgreSQL bundled inside, about 64 MB), the `web` folder (about 8 MB) and a
README. The zip is about 53 MB. On first start the program creates `data/` next to itself. CI builds the zip for
Linux, Windows and macOS.

`tms` takes flags only. Every setting is also a `TMS_*` environment variable or a key in `tms.toml` in the data
folder; `tms --help` lists them. `--database-url` uses an external PostgreSQL instead of the embedded one, and
`--tls-cert`/`--tls-key` serve HTTPS (plain HTTP then redirects).

## Checks

```bash
cargo fmt --all -- --check
cargo clippy --all-targets -- -D warnings
cargo clippy -p tms-client -p tms-ui --target wasm32-unknown-unknown -- -D warnings
cargo test                    # real embedded PostgreSQL per test; also rewrites docs/api/schemas
```

Client clippy needs `crates/tms-client/assets/tailwind.css`, which `dx build` generates.
