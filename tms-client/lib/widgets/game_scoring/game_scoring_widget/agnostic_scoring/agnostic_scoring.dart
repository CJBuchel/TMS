import 'package:flutter/material.dart';

class AgnosticScoringWidget extends StatelessWidget {
  AgnosticScoringWidget({Key? key}) : super(key: key);

  final TextEditingController _scoreController = TextEditingController();

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
            keyboardType: TextInputType.number,
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
