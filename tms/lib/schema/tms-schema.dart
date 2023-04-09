class TmsSchema {
    TmsSchema({
        required this.event,
        required this.gameMatch,
        required this.judgingSession,
        required this.team,
        required this.users,
    });

    Event event;
    GameMatch gameMatch;
    JudgingSession judgingSession;
    Team team;
    User users;
}

class Event {
    Event({
        required this.eventRounds,
        required this.name,
        required this.onlineLink,
        required this.pods,
        required this.season,
        required this.tables,
    });

    int eventRounds;
    String name;
    OnlineLink onlineLink;
    List<String> pods;
    String season;
    List<String> tables;
}

class OnlineLink {
    OnlineLink({
        required this.linked,
        required this.tournamentId,
        required this.tournamentToken,
    });

    bool linked;
    String tournamentId;
    String tournamentToken;
}

class GameMatch {
    GameMatch({
        required this.complete,
        required this.customMatch,
        required this.gameMatchDeferred,
        required this.endTime,
        required this.matchNumber,
        required this.onTableFirst,
        required this.onTableSecond,
        required this.startTime,
    });

    bool complete;
    bool customMatch;
    bool gameMatchDeferred;
    String endTime;
    String matchNumber;
    OnTable onTableFirst;
    OnTable onTableSecond;
    String startTime;
}

class OnTable {
    OnTable({
        required this.scoreSubmitted,
        required this.table,
        required this.teamNumber,
    });

    bool scoreSubmitted;
    String table;
    String teamNumber;
}

class JudgingSession {
    JudgingSession({
        required this.complete,
        required this.customSession,
        required this.judgingSessionDeferred,
        required this.endTime,
        required this.room,
        required this.session,
        required this.startTime,
        required this.teamNumber,
    });

    bool complete;
    bool customSession;
    bool judgingSessionDeferred;
    String endTime;
    String room;
    String session;
    String startTime;
    String teamNumber;
}

class Team {
    Team({
        required this.coreValuesScores,
        required this.gameScores,
        required this.innovationProjectScores,
        required this.ranking,
        required this.robotDesignScores,
        required this.teamAffiliation,
        required this.teamId,
        required this.teamName,
        required this.teamNumber,
    });

    List<JudgingScoresheet> coreValuesScores;
    List<GameScoresheet> gameScores;
    List<JudgingScoresheet> innovationProjectScores;
    int ranking;
    List<JudgingScoresheet> robotDesignScores;
    String teamAffiliation;
    String teamId;
    String teamName;
    String teamNumber;
}

class JudgingScoresheet {
    JudgingScoresheet({
        required this.answers,
        required this.feedbackCrit,
        required this.feedbackPros,
        required this.teamId,
        required this.tournamentId,
    });

    List<Answer> answers;
    String feedbackCrit;
    String feedbackPros;
    String teamId;
    String tournamentId;
}

class Answer {
    Answer({
        required this.answer,
        required this.id,
    });

    String answer;
    String id;
}

class GameScoresheet {
    GameScoresheet({
        required this.answers,
        required this.privateComment,
        required this.publicComment,
        required this.round,
        required this.teamId,
        required this.tournamentId,
    });

    List<Answer> answers;
    String privateComment;
    String publicComment;
    int round;
    String teamId;
    String tournamentId;
}

class User {
    User({
        required this.password,
        required this.username,
    });

    String password;
    String username;
}
