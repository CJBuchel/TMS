import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/referee_scoring/referee_scoring_footer/floating_score.dart';
import 'package:tms/views/referee_scoring/referee_scoring_footer/scoring_footer.dart';
import 'package:tms/views/referee_scoring/referee_scoring_header/scoring_header.dart';
import 'package:tms/views/shared/scoring/game_scoring.dart';
import 'package:tms/views/shared/toolbar/tool_bar.dart';
// import 'package:tms/views/timer/clock.dart';

class RefereeScoring extends StatefulWidget {
  const RefereeScoring({Key? key}) : super(key: key);

  @override
  State<RefereeScoring> createState() => _ScoringScreenState();
}

class _ScoringScreenState extends State<RefereeScoring> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  final ScrollController _scrollController = ScrollController();
  int _score = 0;
  List<ScoreAnswer> _answers = [];
  String _publicComment = "";
  String _privateComment = "";
  List<ScoreError> _errors = [];

  final ValueNotifier<bool> _defaultAnswers = ValueNotifier<bool>(false);
  bool _locked = true;
  GameMatch? _nextMatch;
  Team? _nextTeam;

  set _setPublicComment(String publicComment) {
    if (mounted) {
      setState(() {
        _publicComment = publicComment;
      });
    }
  }

  set _setPrivateComment(String privateComment) {
    if (mounted) {
      setState(() {
        _privateComment = privateComment;
      });
    }
  }

  set _setErrors(List<ScoreError> errors) {
    if (mounted) {
      setState(() {
        _errors = errors;
      });
    }
  }

  set _setAnswers(List<ScoreAnswer> answers) {
    if (mounted) {
      setState(() {
        _answers = answers;
      });
    }
  }

  set _setScore(int score) {
    if (mounted) {
      setState(() {
        _score = score;
      });
    }
  }

  void colorChange() {
    setState(() {});
  }

  void scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  void initState() {
    super.initState();
    AppTheme.isDarkThemeNotifier.addListener(colorChange);
  }

  @override
  void dispose() {
    AppTheme.isDarkThemeNotifier.removeListener(colorChange);
    super.dispose();
  }

  Widget getScoringColumn(double headerHeight, double footerHeight, BoxConstraints constraints) {
    return Column(
      children: [
        SizedBox(
          height: headerHeight,
          width: constraints.maxWidth,
          child: Center(
            child: ScoringHeader(
              height: headerHeight,
              onLock: (locked) {
                setState(() {
                  _locked = locked;
                });
              },
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
                GameScoring(
                  onScore: (score) => _setScore = score,
                  onAnswers: (answers) => _setAnswers = answers,
                  onErrors: (errors) => _setErrors = errors,
                  onPublicCommentChange: (pub) => _setPublicComment = pub,
                  onPrivateCommentChange: (priv) => _setPrivateComment = priv,
                  setDefaultAnswers: _defaultAnswers,
                  onDefaultAnswers: () {
                    _defaultAnswers.value = false; // set to false when default is triggered
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
              locked: _locked,
              score: _score,
              answers: _answers,
              publicComment: _publicComment,
              privateComment: _privateComment,
              onClear: () {
                _defaultAnswers.value = true;
                scrollToTop();
              },
              onSubmit: () {
                _defaultAnswers.value = true;
                scrollToTop();
              },
              onNoShow: () {
                _defaultAnswers.value = true;
                scrollToTop();
              },
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double headerHeight = Responsive.isMobile(context)
        ? 40
        : Responsive.isTablet(context)
            ? 40
            : 45;
    double footerHeight = Responsive.isDesktop(context)
        ? 150
        : Responsive.isTablet(context)
            ? 120
            : 100;

    return Scaffold(
      appBar: const TmsToolBar(),
      body: Container(
        decoration: BoxDecoration(color: (AppTheme.isDarkTheme ? null : Colors.lightBlue[100])),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                getScoringColumn(headerHeight, footerHeight, constraints),
                FloatingScore(footerHeight: footerHeight, score: _score),
              ],
            );
          },
        ),
      ),
    );
  }
}
