// To parse this JSON data, do
//
//     final databaseSchema = databaseSchemaFromJson(jsonString);

import 'dart:convert';

DatabaseSchema databaseSchemaFromJson(String str) => DatabaseSchema.fromJson(json.decode(str));

String databaseSchemaToJson(DatabaseSchema data) => json.encode(data.toJson());

class DatabaseSchema {
    Team team;
    TournamentConfig tournamentConfig;

    DatabaseSchema({
        required this.team,
        required this.tournamentConfig,
    });

    factory DatabaseSchema.fromJson(Map<String, dynamic> json) => DatabaseSchema(
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
