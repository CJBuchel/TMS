// To parse this JSON data, do
//
//     final database = databaseFromJson(jsonString);

import 'dart:convert';

Database databaseFromJson(String str) => Database.fromJson(json.decode(str));

String databaseToJson(Database data) => json.encode(data.toJson());

class Database {
    Team team;
    TournamentConfig tournamentConfig;

    Database({
        required this.team,
        required this.tournamentConfig,
    });

    factory Database.fromJson(Map<String, dynamic> json) => Database(
        team: Team.fromJson(json["_team"]),
        tournamentConfig: TournamentConfig.fromJson(json["_tournament_config"]),
    );

    Map<String, dynamic> toJson() => {
        "_team": team.toJson(),
        "_tournament_config": tournamentConfig.toJson(),
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
    int backupCount;
    int backupInterval;
    int endGameTimerLength;
    String name;
    String season;
    int timerLength;

    TournamentConfig({
        required this.backupCount,
        required this.backupInterval,
        required this.endGameTimerLength,
        required this.name,
        required this.season,
        required this.timerLength,
    });

    factory TournamentConfig.fromJson(Map<String, dynamic> json) => TournamentConfig(
        backupCount: json["backup_count"],
        backupInterval: json["backup_interval"],
        endGameTimerLength: json["end_game_timer_length"],
        name: json["name"],
        season: json["season"],
        timerLength: json["timer_length"],
    );

    Map<String, dynamic> toJson() => {
        "backup_count": backupCount,
        "backup_interval": backupInterval,
        "end_game_timer_length": endGameTimerLength,
        "name": name,
        "season": season,
        "timer_length": timerLength,
    };
}
