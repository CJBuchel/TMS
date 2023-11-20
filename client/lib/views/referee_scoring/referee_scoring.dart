import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/referee_scoring/referee_scoring_footer/floating_score.dart';
import 'package:tms/views/referee_scoring/referee_scoring_footer/scoring_footer.dart';
import 'package:tms/views/referee_scoring/referee_scoring_header/scoring_header.dart';
import 'package:tms/views/shared/scoring/game_scoring.dart';
import 'package:tms/views/shared/toolbar/tool_bar.dart';

class RefereeScoring extends StatelessWidget {
  RefereeScoring({Key? key}) : super(key: key);

  final ScrollController _scrollController = ScrollController();

  // score notifiers
  final ValueNotifier<int> _scoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<List<ScoreAnswer>> _answersNotifier = ValueNotifier<List<ScoreAnswer>>([]);
  final ValueNotifier<List<ScoreError>> _errorsNotifier = ValueNotifier<List<ScoreError>>([]);
  final ValueNotifier<String> _publicCommentNotifier = ValueNotifier<String>("");
  final ValueNotifier<String> _privateCommentNotifier = ValueNotifier<String>("");
  final ValueNotifier<bool> _defaultAnswers = ValueNotifier<bool>(false);

  // team, match and mode notifiers
  final ValueNotifier<bool> _lockedNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<GameMatch?> _nextMatchNotifier = ValueNotifier<GameMatch?>(null);
  final ValueNotifier<Team?> _nextTeamNotifier = ValueNotifier<Team?>(null);

  set _setPublicComment(String publicComment) {
    if (_publicCommentNotifier.value != publicComment) {
      _publicCommentNotifier.value = publicComment;
    }
  }

  set _setPrivateComment(String privateComment) {
    if (_privateCommentNotifier.value != privateComment) {
      _privateCommentNotifier.value = privateComment;
    }
  }

  set _setErrors(List<ScoreError> errors) {
    if (!listEquals(_errorsNotifier.value, errors)) {
      _errorsNotifier.value = errors;
    }
  }

  set _setAnswers(List<ScoreAnswer> answers) {
    if (!listEquals(_answersNotifier.value, answers)) {
      _answersNotifier.value = answers;
    }
  }

  set _setScore(int score) {
    if (_scoreNotifier.value != score) {
      _scoreNotifier.value = score;
    }
  }

  void scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
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
                if (_lockedNotifier.value != locked) {
                  _lockedNotifier.value = locked;
                }
              },
              onNextTeamMatch: (team, match) {
                if (_nextTeamNotifier.value != team) {
                  _nextTeamNotifier.value = team;
                }

                if (_nextMatchNotifier.value != match) {
                  _nextMatchNotifier.value = match;
                }
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

              // score info
              errorsNotifier: _errorsNotifier,
              answersNotifier: _answersNotifier,
              scoreNotifier: _scoreNotifier,
              nextTeamNotifier: _nextTeamNotifier,
              nextMatchNotifier: _nextMatchNotifier,
              lockedNotifier: _lockedNotifier,
              publicCommentNotifier: _publicCommentNotifier,
              privateCommentNotifier: _privateCommentNotifier,

              // callbacks
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
                ValueListenableBuilder(
                  valueListenable: _scoreNotifier,
                  builder: (context, score, _) {
                    return FloatingScore(footerHeight: footerHeight, score: score);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
