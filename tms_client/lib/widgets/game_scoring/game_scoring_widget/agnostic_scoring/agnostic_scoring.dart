import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:tms/providers/robot_game_providers/game_scoring_provider.dart';

class AgnosticScoringWidget extends StatelessWidget {
  final Function(int, String) onScoreChanged;

  AgnosticScoringWidget({
    Key? key,
    required this.onScoreChanged,
  }) : super(key: key);

  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  void _updateScore(int delta) {
    int currentScore = int.tryParse(_scoreController.text) ?? 0;
    int newScore = currentScore + delta;
    if (newScore < 0) {
      newScore = 0;
    }
    _scoreController.text = newScore.toString();
    onScoreChanged(newScore, _commentController.text);
  }

  Widget _buildScoreButton(BuildContext context, String label, int delta, Color color, bool isInverse) {
    double buttonHeight = 50;
    double buttonWidth = 92;
    double padding = 15;
    double fontSize = 16;

    if (ResponsiveBreakpoints.of(context).isDesktop) {
      buttonHeight = 50;
      buttonWidth = 92;
      padding = 15;
      fontSize = 16;
    } else if (ResponsiveBreakpoints.of(context).isTablet) {
      buttonHeight = 40;
      buttonWidth = 80;
      padding = 10;
      fontSize = 14;
    } else if (ResponsiveBreakpoints.of(context).isMobile) {
      buttonHeight = 35;
      buttonWidth = 75;
      padding = 6;
      fontSize = 12;
    }

    if (isInverse) {
      return Padding(
        padding: EdgeInsets.all(padding),
        child: SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: OutlinedButton(
            onPressed: () => _updateScore(delta),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: color),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(left: padding, right: padding, bottom: 10),
        child: SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: () => _updateScore(delta),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _scoreButton(BuildContext context, String label, int delta, Color color) {
    return Column(
      children: [
        _buildScoreButton(context, "+${label}", delta, color, false),
        _buildScoreButton(context, "-${label}", -delta, color, true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _scoreController.text = '0';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Agnostic Scoring',
          style: TextStyle(fontSize: 24),
        ),
        // text field input for agnostic scoring (numerical)

        // cap the size of the text field (500 across)
        Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(20),
          child: Selector<GameScoringProvider, int>(
            selector: (context, provider) => provider.score,
            builder: (context, value, child) {
              if (value.toString() != _scoreController.text) {
                _scoreController.text = value.toString();
              }
              return TextField(
                controller: _scoreController,
                onChanged: (value) {
                  onScoreChanged(int.tryParse(value) ?? 0, _commentController.text);
                },
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  labelText: 'Score',
                  border: OutlineInputBorder(),
                ),
              );
            },
          ),
        ),

        // buttons to increment score by +1, +5, +10, +15, +20, +50, +100
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _scoreButton(context, '50', 50, Colors.red),
            _scoreButton(context, '10', 10, Colors.orange),
            _scoreButton(context, '5', 5, Colors.blue),
            _scoreButton(context, '1', 1, Colors.green),
          ],
        ),
        Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(20),
          child: Selector<GameScoringProvider, String>(
            selector: (context, provider) => provider.privateComment,
            builder: (context, value, child) {
              if (value != _commentController.text) {
                _commentController.text = value;
              }
              return TextField(
                controller: _commentController,
                onChanged: (value) => onScoreChanged(int.tryParse(_scoreController.text) ?? 0, value),
                decoration: const InputDecoration(
                  labelText: 'Private Comment (optional)',
                  border: OutlineInputBorder(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
