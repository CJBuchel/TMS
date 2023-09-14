// To parse this JSON data, do
//
//     final ausfllSchema = ausfllSchemaFromJson(jsonString);

import 'dart:convert';

AusfllSchema ausfllSchemaFromJson(String str) => AusfllSchema.fromJson(json.decode(str));

String ausfllSchemaToJson(AusfllSchema data) => json.encode(data.toJson());

class AusfllSchema {
    DefaultValue defaultValue;
    Game game;
    Games games;
    Mission mission;
    MissionPicture missionPicture;
    QuestionInput questionInput;
    Score score;
    ScoreAnswer scoreAnswer;
    ScoreError scoreError;

    AusfllSchema({
        required this.defaultValue,
        required this.game,
        required this.games,
        required this.mission,
        required this.missionPicture,
        required this.questionInput,
        required this.score,
        required this.scoreAnswer,
        required this.scoreError,
    });

    factory AusfllSchema.fromJson(Map<String, dynamic> json) => AusfllSchema(
        defaultValue: DefaultValue.fromJson(json["default_value"]),
        game: Game.fromJson(json["game"]),
        games: Games.fromJson(json["games"]),
        mission: Mission.fromJson(json["mission"]),
        missionPicture: MissionPicture.fromJson(json["mission_picture"]),
        questionInput: QuestionInput.fromJson(json["question_input"]),
        score: Score.fromJson(json["score"]),
        scoreAnswer: ScoreAnswer.fromJson(json["score_answer"]),
        scoreError: ScoreError.fromJson(json["score_error"]),
    );

    Map<String, dynamic> toJson() => {
        "default_value": defaultValue.toJson(),
        "game": game.toJson(),
        "games": games.toJson(),
        "mission": mission.toJson(),
        "mission_picture": missionPicture.toJson(),
        "question_input": questionInput.toJson(),
        "score": score.toJson(),
        "score_answer": scoreAnswer.toJson(),
        "score_error": scoreError.toJson(),
    };
}

class DefaultValue {
    int? number;
    String? text;

    DefaultValue({
        this.number,
        this.text,
    });

    factory DefaultValue.fromJson(Map<String, dynamic> json) => DefaultValue(
        number: json["Number"],
        text: json["Text"],
    );

    Map<String, dynamic> toJson() => {
        "Number": number,
        "Text": text,
    };
}

class Game {
    List<Mission> missions;

    Game({
        required this.missions,
    });

    factory Game.fromJson(Map<String, dynamic> json) => Game(
        missions: List<Mission>.from(json["missions"].map((x) => Mission.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "missions": List<dynamic>.from(missions.map((x) => x.toJson())),
    };
}

class Mission {
    String? image;
    String prefix;
    String title;

    Mission({
        this.image,
        required this.prefix,
        required this.title,
    });

    factory Mission.fromJson(Map<String, dynamic> json) => Mission(
        image: json["image"],
        prefix: json["prefix"],
        title: json["title"],
    );

    Map<String, dynamic> toJson() => {
        "image": image,
        "prefix": prefix,
        "title": title,
    };
}

class Games {
    Game game2023;

    Games({
        required this.game2023,
    });

    factory Games.fromJson(Map<String, dynamic> json) => Games(
        game2023: Game.fromJson(json["game_2023"]),
    );

    Map<String, dynamic> toJson() => {
        "game_2023": game2023.toJson(),
    };
}

class MissionPicture {
    String prefix;
    String url;

    MissionPicture({
        required this.prefix,
        required this.url,
    });

    factory MissionPicture.fromJson(Map<String, dynamic> json) => MissionPicture(
        prefix: json["prefix"],
        url: json["url"],
    );

    Map<String, dynamic> toJson() => {
        "prefix": prefix,
        "url": url,
    };
}

class QuestionInput {
    Numerical? numerical;
    Categorical? categorical;

    QuestionInput({
        this.numerical,
        this.categorical,
    });

    factory QuestionInput.fromJson(Map<String, dynamic> json) => QuestionInput(
        numerical: json["Numerical"] == null ? null : Numerical.fromJson(json["Numerical"]),
        categorical: json["Categorical"] == null ? null : Categorical.fromJson(json["Categorical"]),
    );

    Map<String, dynamic> toJson() => {
        "Numerical": numerical?.toJson(),
        "Categorical": categorical?.toJson(),
    };
}

class Categorical {
    List<String> options;

    Categorical({
        required this.options,
    });

    factory Categorical.fromJson(Map<String, dynamic> json) => Categorical(
        options: List<String>.from(json["options"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "options": List<dynamic>.from(options.map((x) => x)),
    };
}

class Numerical {
    int max;
    int min;

    Numerical({
        required this.max,
        required this.min,
    });

    factory Numerical.fromJson(Map<String, dynamic> json) => Numerical(
        max: json["max"],
        min: json["min"],
    );

    Map<String, dynamic> toJson() => {
        "max": max,
        "min": min,
    };
}

class Score {
    DefaultValue defaultValue;
    String id;
    String label;
    String labelShort;
    QuestionInput questionInput;

    Score({
        required this.defaultValue,
        required this.id,
        required this.label,
        required this.labelShort,
        required this.questionInput,
    });

    factory Score.fromJson(Map<String, dynamic> json) => Score(
        defaultValue: DefaultValue.fromJson(json["default_value"]),
        id: json["id"],
        label: json["label"],
        labelShort: json["label_short"],
        questionInput: QuestionInput.fromJson(json["question_input"]),
    );

    Map<String, dynamic> toJson() => {
        "default_value": defaultValue.toJson(),
        "id": id,
        "label": label,
        "label_short": labelShort,
        "question_input": questionInput.toJson(),
    };
}

class ScoreAnswer {
    String answer;
    String id;

    ScoreAnswer({
        required this.answer,
        required this.id,
    });

    factory ScoreAnswer.fromJson(Map<String, dynamic> json) => ScoreAnswer(
        answer: json["answer"],
        id: json["id"],
    );

    Map<String, dynamic> toJson() => {
        "answer": answer,
        "id": id,
    };
}

class ScoreError {
    String id;
    String message;

    ScoreError({
        required this.id,
        required this.message,
    });

    factory ScoreError.fromJson(Map<String, dynamic> json) => ScoreError(
        id: json["id"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "message": message,
    };
}
