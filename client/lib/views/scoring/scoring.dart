import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:tms/constants.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/network/network.dart';
import 'package:tms/requests/game_requests.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/scoring/comments.dart';
import 'package:tms/views/scoring/mission.dart';
import 'package:tms/views/scoring/scoring_footer.dart';
import 'package:tms/views/scoring/scoring_header.dart';
import 'package:tms/views/shared/tool_bar.dart';
import 'package:tms/views/timer/clock.dart';

class Scoring extends StatefulWidget {
  const Scoring({Key? key}) : super(key: key);

  @override
  State<Scoring> createState() => _ScoringScreenState();
}

class _ScoringScreenState extends State<Scoring> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  final ScrollController _scrollController = ScrollController();
  List<ScoreAnswer> _answers = [];
  int _score = 0;
  String _publicComment = "";
  String _privateComment = "";
  List<ScoreError> _errors = [];
  GameMatch? _nextMatch;
  Team? _nextTeam;

  Game _game = Game(
    name: "",
    program: "",
    missions: [],
    questions: [],
  );

  void colorChange() {
    setState(() {});
  }

  void setGame(Game game) async {
    if (mounted) {
      setState(() {
        _game = game;
      });
      setDefault();
    }
  }

  void scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  void setDefault() {
    List<ScoreAnswer> answers = [];
    for (var question in _game.questions) {
      if (question.defaultValue.text != null) {
        answers.add(ScoreAnswer(answer: question.defaultValue.text!, id: question.id));
      }
    }

    if (mounted) {
      setState(() {
        _answers = answers;
      });
    }

    getValidateQuestionsRequest(_answers).then((res) {
      if (res.item1 == HttpStatus.ok) {
        if (mounted) {
          setState(() {
            _score = res.item2.item1;
            _errors = res.item2.item2;
          });
        }
      }
    });
  }

  void setAnswer(ScoreAnswer answer) {
    // schedule to set the answers
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        var idx = _answers.indexWhere((a) => a.id == answer.id);
        setState(() {
          if (idx != -1) {
            _answers[idx] = answer;
          } else {
            _answers.add(answer);
          }
        });

        getValidateQuestionsRequest(_answers).then((res) {
          if (res.item1 == HttpStatus.ok) {
            if (mounted) {
              setState(() {
                _score = res.item2.item1;
                _errors = res.item2.item2;
              });
            }
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    AppTheme.isDarkThemeNotifier.addListener(colorChange);
    onGameEventUpdate((game) => setGame(game));

    // delay for 1 second and check if the network is connected, if not use last known game
    Future.delayed(const Duration(seconds: 1), () async {
      if (!await Network.isConnected()) {
        getGame().then((game) => setGame(game));
      }
    });
  }

  @override
  void dispose() {
    AppTheme.isDarkThemeNotifier.removeListener(colorChange);
    super.dispose();
  }

  List<Widget> getMissions() {
    return _game.missions.map((mission) {
      return MissionWidget(
        color: (AppTheme.isDarkTheme ? const Color.fromARGB(255, 69, 80, 100) : Colors.white),
        mission: mission,
        errors: _errors,
        answers: _answers,
        scores: _game.questions.where((q) {
          return q.id.startsWith(mission.prefix);
        }).toList(),
        onAnswers: (subAnswers) {
          for (var answer in subAnswers) {
            setAnswer(answer);
          }
        },
      );
    }).toList();
  }

  Widget getScoringColumn(double headerHeight, double footerHeight, BoxConstraints constraints) {
    return Column(
      children: [
        SizedBox(
          height: headerHeight,
          child: Center(
            child: ScoringHeader(
              height: headerHeight,
              onNextTeamMatch: (team, match) {
                setState(() {
                  _nextTeam = team;
                  _nextMatch = match;
                });
              },
            ),
          ),
        ),
        SizedBox(
          height: constraints.maxHeight - (headerHeight + footerHeight),
          child: Center(
            child: ListView(
              controller: _scrollController,
              cacheExtent: 10000, // 10,000 pixels in every direction
              children: [
                ...getMissions(),
                ScoringComments(
                  color: (AppTheme.isDarkTheme ? const Color.fromARGB(255, 69, 80, 100) : Colors.white),
                  onPublicCommentChange: (pub) {
                    setState(() {
                      _publicComment = pub;
                    });
                  },
                  onPrivateCommentChange: (priv) {
                    setState(() {
                      _privateComment = priv;
                    });
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        SizedBox(
          height: footerHeight,
          child: Center(
            child: ScoringFooter(
              height: footerHeight,
              errors: _errors,
              nextMatch: _nextMatch,
              nextTeam: _nextTeam,
              score: _score,
              answers: _answers,
              publicComment: _publicComment,
              privateComment: _privateComment,
              onClear: () {
                setDefault();
                scrollToTop();
              },
              onSubmit: () {
                setDefault();
                scrollToTop();
              },
              onNoShow: () {
                setDefault();
                scrollToTop();
              },
            ),
          ),
        )
      ],
    );
  }

  Widget getFloatingScore(double footerHeight) {
    return Positioned(
      bottom: footerHeight,
      left: 0,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(10),
            topLeft: Radius.zero,
          ),
          border: Border.all(color: AppTheme.isDarkTheme ? Colors.white : Colors.black),
        ),
        width: 120,
        height: 60,
        child: Center(
          child: Text(
            _score.toString(),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget getFloatingTimer(double headerHeight) {
    return Positioned(
      top: headerHeight,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10),
          ),
          border: Border.all(color: AppTheme.isDarkTheme ? Colors.white : Colors.black),
        ),
        width: 120,
        height: 60,
        child: const Center(
          child: Clock(fontSize: 30),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double headerHeight = Responsive.isTablet(context) ? 50 : 80;
    double footerHeight = Responsive.isDesktop(context)
        ? 150
        : Responsive.isTablet(context)
            ? 100
            : 120;

    return Scaffold(
      appBar: TmsToolBar(),
      body: Container(
        decoration: BoxDecoration(color: (AppTheme.isDarkTheme ? null : Colors.lightBlue[100])),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                getScoringColumn(headerHeight, footerHeight, constraints),
                // getFloatingTimer(headerHeight),
                getFloatingScore(footerHeight),
              ],
            );
          },
        ),
      ),
    );
  }
}
