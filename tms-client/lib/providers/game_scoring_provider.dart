import 'dart:io';

import 'package:tms/generated/infra/fll_infra/fll_blueprint_map.dart';
import 'package:tms/generated/infra/fll_infra/question.dart';
import 'package:tms/generated/infra/network_schemas/robot_game_requests.dart';
import 'package:tms/generated/infra/network_schemas/tournament_config_requests.dart';
import 'package:tms/providers/tournament_blueprint_provider.dart';
import 'package:collection/collection.dart';
import 'package:tms/services/game_scoring_service.dart';
import 'package:tms/utils/logger.dart';

class GameScoringProvider extends TournamentBlueprintProvider {
  final GameScoringService _service = GameScoringService();

  int _score = 0;

  List<QuestionValidationError> _errors = [];
  List<QuestionAnswer> _defaultAnswers = [];
  List<QuestionAnswer> _answers = [];
  List<Question> _gameQuestions = [];

  GameScoringProvider() : super() {
    addListener(_updateQuestions);
  }

  @override
  void dispose() {
    removeListener(_updateQuestions);
    super.dispose();
  }

  // private methods

  void _updateQuestions() {
    if (blueprintType != BlueprintType.agnostic) {
      if (blueprint.robotGameQuestions != _gameQuestions) {
        _gameQuestions = blueprint.robotGameQuestions;

        // get default answers
        _defaultAnswers = blueprint.robotGameQuestions.map((q) {
          return q.input.when(
            categorical: (input) {
              return QuestionAnswer(questionId: q.id, answer: input.defaultOption);
            },
          );
        }).toList();

        // reset answers
        resetAnswers();
      }
    }
  }

  void _updateScore(int score) {
    _score = score;
    // @TODO send score to server/clients
    TmsLogger().i("Score updated: $score");
    notifyListeners();
  }

  Future<int> _calculateScore(List<QuestionAnswer> answers) async {
    return FllBlueprintMap.calculateScore(blueprint: this.blueprint, answers: answers).then((value) {
      _updateScore(value);
      return value;
    });
  }

  Future<List<QuestionValidationError>?> _validateAnswers(List<QuestionAnswer> answers) {
    return FllBlueprintMap.validate(season: this.season, answers: answers).then((errors) {
      if (errors != null) {
        _errors = errors;
      }
      return errors;
    });
  }

  //
  // public access
  //

  // getters
  int get score => _score;
  List<QuestionValidationError> get errors => _errors;
  List<QuestionAnswer> get answers => _answers;
  List<Question> get gameQuestions => _gameQuestions;

  // manual setter for score
  set score(int score) => _updateScore(score);

  void resetAnswers() {
    if (blueprintType == BlueprintType.agnostic) {
      score = 0;
    } else {
      _answers = [..._defaultAnswers]; // copy default answers (don't want the origin modified)
      onAnswers(_answers);
    }
  }

  String? getAnswer(String questionId) {
    return _answers.firstWhereOrNull((a) => a.questionId == questionId)?.answer;
  }

  String? getValidationErrorMessage(String questionId) {
    return _errors.firstWhereOrNull((e) => e.questionIds.contains(questionId))?.message;
  }

  Future<(int, List<QuestionValidationError>?)> onAnswers(List<QuestionAnswer> answers) async {
    _answers = answers;
    int score = await _calculateScore(answers);
    List<QuestionValidationError>? errors = await _validateAnswers(answers);
    return (score, errors);
  }

  Future<(int, List<QuestionValidationError>?)> onAnswer(QuestionAnswer answer) async {
    // check if answer exists and change it. Otherwise add it.
    int index = _answers.indexWhere((a) => a.questionId == answer.questionId);
    if (index != -1) {
      _answers[index] = answer;
    } else {
      _answers.add(answer);
    }
    return await onAnswers(_answers);
  }

  //
  // helper methods (submissions and validations)
  //
  bool isValid() {
    return _errors.isEmpty;
  }

  //
  // server communication
  //
  Future<int> submitScoreSheet({
    required String table,
    required String teamNumber,
    String? matchNumber,
    required int round,
    bool noShow = false,
  }) async {
    if (isValid()) {
      // get gp out of answers
      String gp = _answers.firstWhere((a) => a.questionId == "gp").answer;

      // create the score sheet
      var scoreSheet = RobotGameScoreSheetRequest(
        table: table,
        teamNumber: teamNumber,
        referee: "@TODO",
        matchNumber: matchNumber,
        gp: gp,
        noShow: noShow,
        score: score,
        round: round,
        isAgnostic: blueprintType == BlueprintType.agnostic,
        scoreSheetAnswers: _answers,
        privateComment: "@TODO",
      );

      return _service.submitScoreSheet(scoreSheet);
    } else {
      return HttpStatus.badRequest;
    }
  }

  // submit no show
  Future<int> submitNoShow({
    required String table,
    required String teamNumber,
    String? matchNumber,
    required int round,
  }) {
    return submitScoreSheet(
      table: table,
      teamNumber: teamNumber,
      matchNumber: matchNumber,
      round: round,
      noShow: true,
    );
  }
}
