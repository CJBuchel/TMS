
## Runner (Dev)
- Run server using `cd ./server; conduit run serve`
- Run tms using `cd ./tms; flutter run -d chrome` (Can also be `-d linux` or any other native device)

## Plan
- For a user, there should be two methods used for hosting the TMS service
1. An All in one Docker container which runs mongo, the server and the web service. The AIO container (All In One)
2. A docker container which runs mongo and the server, and then the client is either distributed separately or run in it's own setting.

- The main preference for most should be to always run the AIO container, then to also have the TMS client application distributed as well.
### Implementation
- Flutter should be the front end due to it's high cross compatibility
- Rust is the backend, which will implement sled for the database and websocket comms + Actix for http requests
