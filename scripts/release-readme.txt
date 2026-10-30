TMS - FIRST LEGO League tournament management
=============================================

Start the server
----------------
Keep this folder together: the tms program serves the web client from the web folder next to it.

  Windows:        double-click tms.exe, or run  tms.exe --headless  in a terminal
  macOS, Linux:   ./tms --headless

The server prints the addresses to open on other devices and a QR code. Log in as "admin" with the password
"admin", or set your own in the launcher's Server tab (or with --admin-password). Press Ctrl+C to stop it.

Your data
---------
The first start creates a "data" folder here. It holds the database, the logs and the backups. To move TMS to
another computer, stop it and copy this whole folder.

Useful options
--------------
  --port 8080            the web port (default 8080)
  --data-dir PATH        keep the data somewhere else
  --web-dir PATH         serve the web client from another folder
  --database-url URL     use an existing PostgreSQL server instead of the built-in one
  --tls-cert, --tls-key  serve HTTPS
  --help                 every option

Settings can also go in data/tms.toml, using the same names without the dashes in front (port = 8080).
