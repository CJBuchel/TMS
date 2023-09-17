import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/screens/scoring/mission.dart';
import 'package:tms/screens/scoring/question.dart';
import 'package:tms/screens/shared/tool_bar.dart';

class Scoring extends StatefulWidget {
  const Scoring({Key? key}) : super(key: key);

  @override
  _ScoringScreenState createState() => _ScoringScreenState();
}

class _ScoringScreenState extends State<Scoring> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  Game _game = Game(
    name: "",
    program: "",
    missions: [],
    questions: [],
  );

  @override
  void initState() {
    super.initState();
    onGameEventUpdate((game) {
      setState(() {
        _game = game;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TmsToolBar(),
      body: ListView.builder(
        cacheExtent: 10000, // 10,000 pixels in every direction
        itemCount: _game.missions.length,
        itemBuilder: (context, index) {
          return MissionWidget(
            mission: _game.missions[index],
            scores: _game.questions.where((q) {
              return q.id.startsWith(_game.missions[index].prefix);
            }).toList(),
          );
        },
      ),
    );
  }
}
