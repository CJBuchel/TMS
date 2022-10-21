# Servers
- There are two servers which are active during runtime. (Comm Server and Request Server)

## CommServer
- CommServer is simple and is used for pub sub messaging. Built for small messages at fast pace, (clock times, and small state changes)

## RequestServer
- The main server for the service, built for slower messages but large datasets
- Used for updates to database and holds the main server side timing and other services.

# Interfaces
- There are 6 interfaces. (Admin, Clock/Timer, MatchControl, Scorer, Display, CentralStats)

### Admin
- Main page for admin, and first time setup

### Clock/Timer/Match Display
- A single page interface that displays the timer and current match info.

### Match Control
- A multi page interface that provides the full controls for the timer as well as the scoring progress and team score changes
- Often provided to the head ref which can change the current match as well as reschedule matches and change team scores.

### Scorer
- Multi page interface holding manual scoring. And calculated scoring
- The public npm calculator module for the FLL dashboard https://github.com/fwestling/ausfll-score-calculator

### Audience Display
- A single page interface with no login. Dynamically changes content based on current events and admin controls

### Central Stats
- Displays statistics for teams and team scores. Also allows exporting of team score csv