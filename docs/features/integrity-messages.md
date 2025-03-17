# Integrity Checks

## Overview
TMS has an integrity system build in to catch common mistakes and problems that can be found during an event. Specifically that related to Teams, Judging Sessions and Game Matches.

- The integrity system runs as a service in the background that passes over the database every 10 seconds to verify common mistakes.
- Common issues flagged by the integrity checks include: Score duplication, teams with less matches than others, session time conflicts and more.
- Depending on the severity of the issue, the system will either flag the issue as a warning or an error. And will provide a code and message to help identify the issue.

!!! warning "Integrity checks are not exhaustive"
    The integrity checks are not exhaustive and may not find all issues. And therefore it's not recommended to rely on issues being flagged to determine if an Event is good to run.

## Warning Codes
| Code | Description |
|------|-------------|
| W000 | (Unknown Warning) This is the default warning. Usually implying it could not infer the warning type. |
| W001 | Team name is missing. |
| W002 | Duplicate team name. |
| W003 | Team has a round 0 score. |
| W004 | No tables or teams found in match. |
| W005 | Match is complete but score not submitted. |
| W006 | Match is not complete but score submitted. |
| W007 | Blank table in match. |
| W008 | No team on table. |
| W009 | Team has judging session within 10 minutes of match. |
| W010 | No pods or teams found in sessions. |
| W011 | Session Complete, but no core values score submitted. |
| W012 | Session Complete, but no innovation score submitted. |
| W013 | Session Complete, but no robot design score submitted. |
| W014 | Session not Complete, but core values score submitted. |
| W015 | Session not Complete, but innovation score submitted. |
| W016 | Session not Complete, but robot design score submitted. |
| W017 | Blank pod in session. |
| W018 | No team in pod. |

## Error Codes
| Code | Description |
|------|-------------|
| E000 | (Unknown Error) This is the default error, usually implying it could not infer the error type. |
| E001 | Team number is missing. |
| E002 | Duplicate team number. |
| E003 | Team has conflicting scores. |
| E004 | Table does not exist in event. |
| E005 | Team in match does not exist in this event. |
| E006 | Duplicate match number. |
| E007 | Team has fewer matches than the maximum number of rounds. |
| E008 | Pod does not exist in event. |
| E009 | Team in pod does not exist in this event. |
| E010 | Team has more than one judging session. |
| E011 | Team is not in any judging sessions. |
| E012 | Duplicate session number. |
| E013 | Team has match overlapping with Judging session. |

!!! note "More integrity checks"
    Above includes the checks that are currently implemented in the integrity system. More checks may be added in the future. If you have a suggestion for a new check, please raise a [change request].

[change request]: https://cjbuchel.github.io/TMS/support/change-requests/