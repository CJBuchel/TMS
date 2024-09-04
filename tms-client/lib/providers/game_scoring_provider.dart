import 'package:tms/generated/infra/fll_infra/fll_blueprint_map.dart';
import 'package:tms/generated/infra/fll_infra/question.dart';
import 'package:tms/providers/tournament_blueprint_provider.dart';
import 'package:tms/utils/logger.dart';

class GameScoringProvider extends TournamentBlueprintProvider {
  int _score = 0;

  List<QuestionValidationError> _errors = [];
  List<QuestionAnswer> _answers = [];
  List<Question> _gameQuestions = [];
  List<QuestionAnswer> _defaultAnswers = [];

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
    _answers = _defaultAnswers;
    onAnswers(_answers);
  }

  String getValidationErrorMessage(String questionId) {
    QuestionValidationError error = _errors.firstWhere(
      (e) => e.questionIds.contains(questionId),
      orElse: () => const QuestionValidationError(questionIds: "", message: ""),
    );
    return error.message;
  }

  Future<(int, List<QuestionValidationError>?)> onAnswers(List<QuestionAnswer> answers) async {
    TmsLogger().w("onAnswers called...");
    _answers = answers;
    int score = await _calculateScore(answers);
    List<QuestionValidationError>? errors = await _validateAnswers(answers);
    TmsLogger().w("onAnswers: $score, $errors");
    return (score, errors);
  }

  Future<(int, List<QuestionValidationError>?)> onAnswer(QuestionAnswer answer) async {
    // check if answer exists and change it. Otherwise add it.
    TmsLogger().w("onAnswer: $answer");
    int index = _answers.indexWhere((a) => a.questionId == answer.questionId);
    if (index != -1) {
      _answers[index] = answer;
    } else {
      _answers.add(answer);
    }
    return await onAnswers(_answers);
  }
}
