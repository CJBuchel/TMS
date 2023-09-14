import 'package:flutter/material.dart';

class Scoring extends StatefulWidget {
  const Scoring({Key? key}) : super(key: key);

  @override
  _ScoringScreenState createState() => _ScoringScreenState();
}

class _ScoringScreenState extends State<Scoring> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scoring'),
      ),
      body: const Center(
        child: Text('Scoring'),
      ),
    );
  }
}
