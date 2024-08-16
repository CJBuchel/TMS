import 'package:flutter/material.dart';

class GameScoringProvider extends ChangeNotifier {
  int _score = 0;

  int get score => _score;

  void incrementScore() {
    _score++;
    notifyListeners();
  }

  void decrementScore() {
    _score--;
    notifyListeners();
  }
}
