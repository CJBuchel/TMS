# Live feed (WebSocket)

TMS pushes live data over one WebSocket per client at `/ws` (`wss://` when the server uses HTTPS).
Commands never go over the socket: every change is a REST call under `/api/v1`, and the socket carries the result to everyone who is listening.

Every frame is a JSON text message with a `type` field. JSON Schemas for both directions are in [`schemas/ws-client-message.json`](schemas/ws-client-message.json) and [`schemas/ws-server-message.json`](schemas/ws-server-message.json).

## Handshake

1. Open the socket.
2. Send `hello` within 5 seconds. `token` is a login token (JWT) from `POST /api/v1/auth/login` or `POST /api/v1/auth/key`, or `null` for public topics only.
3. The server answers `welcome` with its clock and your roles. An invalid token gets `error` with code `auth.required`, then the socket closes.

If the login is ended while connected (logout elsewhere, password change, revoked access key), the server sends `error` with code `auth.revoked` and closes the socket. Log in again before reconnecting.

```json
{"type":"hello","v":1,"token":"6f1c…","client_build":"my-tool 1.0"}
{"type":"welcome","v":1,"server_ms":1793000000000,"roles":["referee"]}
```

`v` is the protocol version. A mismatch gets `error` with code `ws.protocol_version`.

## Subscriptions

Send the **complete** set of topics you want. Each `set_subscriptions` replaces the previous set. Duplicates are ignored.

```json
{"type":"set_subscriptions","topics":["event","banners"]}
```

For every topic that was not already subscribed, the server sends a `snapshot` with the topic's full contents. After that it sends `upsert` and `delete` deltas as data changes. Topics you drop simply stop arriving.

```json
{"type":"snapshot","topic":"banners","items":[{"kind":"banner","data":{"id":"0192…","event_id":"0192…","severity":"warning","message":"Lunch delayed by 15 minutes","created_at":"2026-11-14T02:10:00Z"}}]}
{"type":"upsert","topic":"banners","item":{"kind":"banner","data":{"...": "..."}}}
{"type":"delete","topic":"banners","id":"0192…"}
```

Every item is `{"kind": ..., "data": {...}}`; apply deltas by `data.id`. A `snapshot` always replaces what you hold for that topic. The server may send a fresh `snapshot` at any time, for example when a different event is activated or when your connection fell behind.

Because the full set is sent each time, a client never has to track unsubscribes. The TMS web client counts how many on-screen components use each topic and sends the set of topics with a count above zero, debounced by 50 ms.

### Topics

| Topic | Contents | Who may read |
|---|---|---|
| `event` | The active event (zero or one item, `kind: "event"`) | Anyone |
| `banners` | Active announcement banners for the active event (`kind: "banner"`) | Anyone |
| `teams` | Teams (`kind: "team"`) | Anyone |
| `tables` | Competition tables, paired by `sort_order` (`kind: "table"`) | Anyone |
| `pods` | Judging pods (`kind: "pod"`) | Anyone |
| `matches` | Matches with their `state`, each with its table/team `slots`: the team's `round`, its `queue` state, and the slot's scoresheet status (`kind: "match"`) | Anyone |
| `judging_sessions` | Judging sessions, each with its pod/team `slots` (`kind: "judging_session"`) | Anyone |
| `blocks` | Timetable blocks such as lunch (`kind: "block"`) | Anyone |
| `timer` | The match timer, keyed by the event id (`kind: "timer"`). Every phase follows from `starts_at` and the clock, so devices compute time left locally | Anyone |
| `rankings` | One row per team in ranking order (`kind: "ranking"`, keyed by `team_id`). Sent as a fresh snapshot whenever a scoresheet changes | Anyone |
| `scoresheets` | Every scoresheet of the event (`kind: "scoresheet"`) | Referee and above |
| `presence` | Station devices logged in with an access key and connected now (`kind: "presence"`, keyed by `key_id`) | Head referee, judge advisor |
| `pod_timers` | One timer per pod (`kind: "pod_timer"`, keyed by `pod_id`): session, phase and when it ends | Anyone |
| `rubrics` | Every rubric of the event (`kind: "rubric"`) | Judge and above |
| `deliberation` | One item keyed by the event id (`kind: "deliberation"`): scores, ranks, selections, awards, winners, advancement, finalized | Judge advisor |
| `ceremony` | One item keyed by the event id (`kind: "ceremony"`): how many slides are shown of how many, and only the revealed slides | Anyone |
| `issues` | Schedule check results (`kind: "issue"`, keyed by an id that stays the same for the same problem). An edit re-checks only the teams it touched and pushes just the issues that changed | Head referee, judge advisor |

Topic strings are `name`, `name/<id>` or `name?<key>=<id>`. More topics are added as features land. An unknown topic string gets `error` with code `ws.bad_message`, and a topic your role may not read gets `ws.topic_forbidden`.

## Keepalive and clock

- The server sends `{"type":"ping"}` every 10 seconds. Answer `{"type":"pong"}`. Two unanswered pings close the socket.
- Send `{"type":"time_sync","client_ms":<your epoch ms>}` to measure clock offset. The server echoes it with `server_ms`. Offset ≈ `server_ms + round_trip/2 - now`. The web client keeps the median of the last five samples and uses server time for every timer.

## Reconnecting

Reconnect with exponential backoff (the web client uses 1 s doubling to 16 s), send `hello` again, then your current `set_subscriptions`. The snapshots that follow replace anything stale.
