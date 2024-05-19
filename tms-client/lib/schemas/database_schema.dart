// To parse this JSON data, do
//
//     final databaseSchema = databaseSchemaFromJson(jsonString);

import 'dart:convert';

DatabaseSchema databaseSchemaFromJson(String str) => DatabaseSchema.fromJson(json.decode(str));

String databaseSchemaToJson(DatabaseSchema data) => json.encode(data.toJson());

class DatabaseSchema {
    GameMatch gameMatch;
    JudgingSession judgingSession;
    Team team;
    TournamentConfig tournamentConfig;

    DatabaseSchema({
        required this.gameMatch,
        required this.judgingSession,
        required this.team,
        required this.tournamentConfig,
    });

    factory DatabaseSchema.fromJson(Map<String, dynamic> json) => DatabaseSchema(
        gameMatch: GameMatch.fromJson(json["_game_match"]),
        judgingSession: JudgingSession.fromJson(json["_judging_session"]),
        team: Team.fromJson(json["_team"]),
        tournamentConfig: TournamentConfig.fromJson(json["_tournament_config"]),
    );

    Map<String, dynamic> toJson() => {
        "_game_match": gameMatch.toJson(),
        "_judging_session": judgingSession.toJson(),
        "_team": team.toJson(),
        "_tournament_config": tournamentConfig.toJson(),
    };
}

class GameMatch {
    TmsDateTime endTime;
    List<GameMatchTable> gameMatchTables;
    String matchNumber;
    TmsDateTime startTime;

    GameMatch({
        required this.endTime,
        required this.gameMatchTables,
        required this.matchNumber,
        required this.startTime,
    });

    factory GameMatch.fromJson(Map<String, dynamic> json) => GameMatch(
        endTime: TmsDateTime.fromJson(json["end_time"]),
        gameMatchTables: List<GameMatchTable>.from(json["game_match_tables"].map((x) => GameMatchTable.fromJson(x))),
        matchNumber: json["match_number"],
        startTime: TmsDateTime.fromJson(json["start_time"]),
    );

    Map<String, dynamic> toJson() => {
        "end_time": endTime.toJson(),
        "game_match_tables": List<dynamic>.from(gameMatchTables.map((x) => x.toJson())),
        "match_number": matchNumber,
        "start_time": startTime.toJson(),
    };
}

class TmsDateTime {
    TmsDate? date;
    TmsTime? time;

    TmsDateTime({
        this.date,
        this.time,
    });

    factory TmsDateTime.fromJson(Map<String, dynamic> json) => TmsDateTime(
        date: json["date"] == null ? null : TmsDate.fromJson(json["date"]),
        time: json["time"] == null ? null : TmsTime.fromJson(json["time"]),
    );

    Map<String, dynamic> toJson() => {
        "date": date?.toJson(),
        "time": time?.toJson(),
    };
}

class TmsDate {
    int day;
    int month;
    int year;

    TmsDate({
        required this.day,
        required this.month,
        required this.year,
    });

    factory TmsDate.fromJson(Map<String, dynamic> json) => TmsDate(
        day: json["day"],
        month: json["month"],
        year: json["year"],
    );

    Map<String, dynamic> toJson() => {
        "day": day,
        "month": month,
        "year": year,
    };
}

class TmsTime {
    int hour;
    int minute;
    int second;

    TmsTime({
        required this.hour,
        required this.minute,
        required this.second,
    });

    factory TmsTime.fromJson(Map<String, dynamic> json) => TmsTime(
        hour: json["hour"],
        minute: json["minute"],
        second: json["second"],
    );

    Map<String, dynamic> toJson() => {
        "hour": hour,
        "minute": minute,
        "second": second,
    };
}

class GameMatchTable {
    bool scoreSubmitted;
    String table;
    String teamNumber;

    GameMatchTable({
        required this.scoreSubmitted,
        required this.table,
        required this.teamNumber,
    });

    factory GameMatchTable.fromJson(Map<String, dynamic> json) => GameMatchTable(
        scoreSubmitted: json["score_submitted"],
        table: json["table"],
        teamNumber: json["team_number"],
    );

    Map<String, dynamic> toJson() => {
        "score_submitted": scoreSubmitted,
        "table": table,
        "team_number": teamNumber,
    };
}

class JudgingSession {
    TmsDateTime endTime;
    List<JudgingSessionPod> judgingSessionPods;
    String sessionNumber;
    TmsDateTime startTime;

    JudgingSession({
        required this.endTime,
        required this.judgingSessionPods,
        required this.sessionNumber,
        required this.startTime,
    });

    factory JudgingSession.fromJson(Map<String, dynamic> json) => JudgingSession(
        endTime: TmsDateTime.fromJson(json["end_time"]),
        judgingSessionPods: List<JudgingSessionPod>.from(json["judging_session_pods"].map((x) => JudgingSessionPod.fromJson(x))),
        sessionNumber: json["session_number"],
        startTime: TmsDateTime.fromJson(json["start_time"]),
    );

    Map<String, dynamic> toJson() => {
        "end_time": endTime.toJson(),
        "judging_session_pods": List<dynamic>.from(judgingSessionPods.map((x) => x.toJson())),
        "session_number": sessionNumber,
        "start_time": startTime.toJson(),
    };
}

class JudgingSessionPod {
    bool coreValuesSubmitted;
    bool innovationSubmitted;
    String pod;
    bool robotDesignSubmitted;
    String teamNumber;

    JudgingSessionPod({
        required this.coreValuesSubmitted,
        required this.innovationSubmitted,
        required this.pod,
        required this.robotDesignSubmitted,
        required this.teamNumber,
    });

    factory JudgingSessionPod.fromJson(Map<String, dynamic> json) => JudgingSessionPod(
        coreValuesSubmitted: json["core_values_submitted"],
        innovationSubmitted: json["innovation_submitted"],
        pod: json["pod"],
        robotDesignSubmitted: json["robot_design_submitted"],
        teamNumber: json["team_number"],
    );

    Map<String, dynamic> toJson() => {
        "core_values_submitted": coreValuesSubmitted,
        "innovation_submitted": innovationSubmitted,
        "pod": pod,
        "robot_design_submitted": robotDesignSubmitted,
        "team_number": teamNumber,
    };
}

class Team {
    String affiliation;
    String cloudId;
    String name;
    String number;
    int ranking;

    Team({
        required this.affiliation,
        required this.cloudId,
        required this.name,
        required this.number,
        required this.ranking,
    });

    factory Team.fromJson(Map<String, dynamic> json) => Team(
        affiliation: json["affiliation"],
        cloudId: json["cloud_id"],
        name: json["name"],
        number: json["number"],
        ranking: json["ranking"],
    );

    Map<String, dynamic> toJson() => {
        "affiliation": affiliation,
        "cloud_id": cloudId,
        "name": name,
        "number": number,
        "ranking": ranking,
    };
}

class TournamentConfig {
    int backupInterval;
    int endGameTimerLength;
    String name;
    int retainBackups;
    String season;
    int timerLength;

    TournamentConfig({
        required this.backupInterval,
        required this.endGameTimerLength,
        required this.name,
        required this.retainBackups,
        required this.season,
        required this.timerLength,
    });

    factory TournamentConfig.fromJson(Map<String, dynamic> json) => TournamentConfig(
        backupInterval: json["backup_interval"],
        endGameTimerLength: json["end_game_timer_length"],
        name: json["name"],
        retainBackups: json["retain_backups"],
        season: json["season"],
        timerLength: json["timer_length"],
    );

    Map<String, dynamic> toJson() => {
        "backup_interval": backupInterval,
        "end_game_timer_length": endGameTimerLength,
        "name": name,
        "retain_backups": retainBackups,
        "season": season,
        "timer_length": timerLength,
    };
}
