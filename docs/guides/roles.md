# Who does what

People log in with a username and password; station tablets log in with an access key. A login with one job opens straight to its screen (a referee key to the referee station, a head referee to match control) and gets the whole width. Admins, and anyone with several roles, land on Home and choose. Everything else is under **Menu** at the top left: other screens, Settings, the venue screens, theme, full screen and Log out.

## Admin

**Home** is the admin's overview while the event runs: event health, what is on the field, any **missing scoresheets**, every table, the station devices, and announcements.

- A missing scoresheet says what its table's tablet holds: a sheet waiting to send (the tablet keeps trying), nothing, or that the tablet is offline. **Enter sheet** types in a paper sheet; **Mark no show** records, with a reason, that the team did not really play, so the match stops waiting. Undo it from the finished match's row in Match control.
- **Announcements** show across the top of every logged-in device until cleared.
- Your own login: add yourself under Users with a password you choose. Keep `admin` for recovery; its password can always be set from the launcher.

Before the event, in Event setup:

1. **Event:** create the event and make it active. Set the match length, the number of rounds, the judging session times, how scoresheets and rubrics are reviewed, and how many teams advance.
2. **Teams, Tables & pods:** enter them, or let a schedule import add them.
3. **Schedule:** either generate the schedule (first match, first judging session, match cycle), or import the Tournament-in-a-Box CSV. Add lunch and ceremonies on the timetable first, so the generator keeps clear of them. Fix anything the schedule checks list. Click any team in the tables to change it, swap it, or move the match or session.
4. **Awards:** add the optional and local awards the event presents, set places, and order the ceremony.
5. **Users:** create logins for the head referee, judge advisor, queuers, emcee and any other people. Give a password, or leave it empty for a one-time password they change at first login.
6. **Access keys:** **Keys for every table and pod** makes one for each station that has none and shows them as printable cards. Each card's QR code logs a tablet straight into its station. Keys are shown only then, so print the cards or scan them straight away.
7. **Print:** team schedules, signs and paper scoresheets.

## Head referee

- **Match control:** stage the next match (when nothing is staged, the timer panel offers the next one), start it when the teams are ready, and end or abort it. Each staged team's card shows how far it has got from Called to Ready.
- **Scoresheet review:** publish or reject flagged sheets, or every sheet if the event reviews them all.
- The top bar shows schedule errors, and the device list shows which table tablets are connected.

## Referee

- On the table tablet (access key): **Referee station** shows the team due at that table, with one big button for the next step: Team at table, then Ready. After the match, the team to score comes first.
- The team confirms the sheet before it is submitted.

## Queuer

- **Queue board:** pick your tables once (the tablet remembers them). Each team is a card with one big button for the next step: Call team, On the way, In the queue. A team that turns up by itself can go straight to the queue.
- Teams show as **Soon**, then **Queue now**, then **Late**, from the times in Event setup → Event → Queueing. Late teams come first.
- If the tablet loses Wi-Fi, a tap is kept and sent when it is back; the card says so.
- The **Judging** tab does the same for the judging rooms.
- The queue screen in the pits shows the teams to come now and the ones to get ready.

## Judge

- On the pod tablet (access key): **Judge station** shows the pod's sessions.
- Take the team into the room and run the session on the pod timer.
- Fill in both rubrics and the feedback, and submit. Rubrics are kept on the tablet until they reach the server.

## Judge advisor

- **Judging:** every pod's timer and progress, plus rubric review.
- **Scores:** each area's score and rank, as the Official Judging Spreadsheet computes them.
- **Deliberation:** allocate awards step by step in the official order, choose the advancing teams, and finalize. Finalizing locks rubrics and awards and lets the ceremony start.
- **Exports:** CSV files that paste into the Official Judging Spreadsheet.

## Emcee

- **Emcee:** start matches with the countdown and announce the top of the ranking.
- During the awards ceremony, reveal each award on the venue screen. The page shows what comes next so you can read it out.

## Venue screens

These need no login. The login page links them, and `/display` lists them all, so a TV only needs the server's address. Open one and go full screen (F11):

- `/display/scoreboard`
- `/display/timer`
- `/display/queue`
- `/display/schedule`
- `/display/awards`
