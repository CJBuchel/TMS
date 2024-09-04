import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AgnosticScoringWidget extends StatelessWidget {
  final Function(int) onScoreChanged;

  AgnosticScoringWidget({
    Key? key,
    required this.onScoreChanged,
  }) : super(key: key);

  final TextEditingController _scoreController = TextEditingController();

  // @TODO
  // add multiple buttons to increment score by +1, +5, +10, +15, +20, +50, +100
  // and decrement (along with the text field)

  @override
  Widget build(BuildContext context) {
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
          child: TextField(
            controller: _scoreController,
            onChanged: (value) {
              onScoreChanged(int.tryParse(value) ?? 0);
            },
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              labelText: 'Enter Score',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
