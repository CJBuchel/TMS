import 'package:flutter/material.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/sorter_util.dart';

class TeamTable extends StatefulWidget {
  final int rounds;
  final List<Team> teams;
  final List<GameMatch> matches;

  const TeamTable({
    Key? key,
    required this.rounds,
    required this.teams,
    required this.matches,
  }) : super(key: key);

  @override
  State<TeamTable> createState() => _TeamTableState();
}

class _TeamTableState extends State<TeamTable> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  late ScrollController _scrollController;
  late AnimationController _animationController;
  bool _animationInitialized = false;
  bool _animationHasEverBeenInitialized = false;
  final Color nthRowColor = const Color.fromARGB(255, 218, 218, 218);

  final int _scrollSpeed = 2;
  static const double rowHeight = 40.0; // change this later to be dynamic, but I know that the rows are all 50
  static const double headerHeight = 50;

  void initializeInfiniteAnimation() {
    _animationHasEverBeenInitialized = true;
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.teams.length * _scrollSpeed),
    )
      ..addListener(() {
        double resetPosition = widget.teams.length * rowHeight; // Position where the second table starts
        double currentScroll = _animationController.value * resetPosition * 2; // Scrolling through double the data

        if (currentScroll >= resetPosition) {
          _animationController.forward(from: 0.0);
        } else {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(currentScroll);
          }
        }
      })
      ..repeat();
  }

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.teams.isNotEmpty) {
        initializeInfiniteAnimation();
        _animationInitialized = true;
      } else {
        _animationInitialized = false;
      }
    });
  }

  @override
  void didUpdateWidget(covariant TeamTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget != oldWidget) {
      if (widget.teams.isNotEmpty) {
        if (!_animationInitialized) {
          initializeInfiniteAnimation();
          _animationInitialized = true;
        }
      } else {
        _animationInitialized = false;
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (_animationHasEverBeenInitialized) {
      _animationController.dispose();
    }
    super.dispose();
  }

  Widget _buildCell(String text, {Color? backgroundColor, Color? textColor, double? width}) {
    return Container(
      width: width,
      color: backgroundColor,
      child: Center(child: Text(text, style: TextStyle(color: textColor, overflow: TextOverflow.ellipsis))),
    );
  }

  Widget _buildHeader(double rankWidth, double teamWidth) {
    return SizedBox(
      height: headerHeight,
      // Color(0xff4FC3A1) // green
      // Color(0xff324960) // blue
      child: Row(
        children: [
          _buildCell("Rank", backgroundColor: const Color(0xff4FC3A1), textColor: Colors.white, width: rankWidth),
          _buildCell("Team", backgroundColor: const Color(0xff324960), textColor: Colors.white, width: teamWidth),
          ...List.generate(widget.rounds, (index) {
            return Expanded(
              child: _buildCell(
                "Round ${index + 1}",
                backgroundColor: index.isEven ? const Color(0xff4FC3A1) : const Color(0xff324960),
                textColor: Colors.white,
              ),
            );
          }),
        ],
      ),
    );
  }

  List<Widget> _getRoundScores(Team team, Color backgroundColor) {
    // Initialize a map to hold scores for each round
    Map<int, List<TeamGameScore>> scores = Map<int, List<TeamGameScore>>(); // <round number, List<TeamGameScores>>

    // Populate the map with scores
    for (var gameScore in team.gameScores) {
      scores.putIfAbsent(gameScore.scoresheet.round, () => []).add(gameScore);
    }

    // Generate widgets for each round
    return List.generate(widget.rounds, (index) {
      int round = index + 1; // Assuming rounds start from 1
      String displayText;

      if (scores.containsKey(round)) {
        // Check if there are multiple scores for this round and display "Conflict" if true
        displayText = scores[round]!.length > 1 ? "Conflict" : scores[round]!.first.score.toString();
        displayText = scores[round]!.first.noShow ? "-" : displayText;
      } else {
        // Display some placeholder or empty string if no scores are found for this round
        displayText = "";
      }

      return Expanded(
        child: _buildCell(
          displayText,
          backgroundColor: backgroundColor,
          textColor: Colors.black,
        ),
      );
    });
  }

  Widget _buildRow(double rankWidth, double teamWidth, Team team, Color rowColor, int rounds) {
    return SizedBox(
      height: rowHeight,
      child: Row(
        children: [
          _buildCell(team.ranking.toString(), backgroundColor: rowColor, textColor: Colors.black, width: rankWidth),
          _buildCell(team.teamName, backgroundColor: rowColor, textColor: Colors.black, width: teamWidth),
          ..._getRoundScores(team, rowColor),
        ],
      ),
    );
  }

  Widget infiniteTable(double rankWidth, double teamWidth) {
    List<Team> teams = sortTeamsByRank(widget.teams);
    return ListView.builder(
      controller: _scrollController,
      itemCount: teams.length * 2, // double the data for seamless scrolling
      itemBuilder: (context, index) {
        return _buildRow(
          rankWidth,
          teamWidth,
          teams[index % teams.length],
          index.isEven ? Colors.white : nthRowColor,
          widget.rounds,
        );
      },
    );
  }

  Widget staticTable(double rankWidth, double teamWidth) {
    return ListView.builder(
      itemCount: widget.teams.length,
      itemBuilder: (context, index) {
        return _buildRow(
          rankWidth,
          teamWidth,
          widget.teams[index],
          index.isEven ? Colors.white : nthRowColor,
          widget.rounds,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double rankWidth = Responsive.isDesktop(context)
        ? 100
        : Responsive.isTablet(context)
            ? 80
            : 60;

    double teamWidth = Responsive.isDesktop(context)
        ? 550
        : Responsive.isTablet(context)
            ? 350
            : 150;

    // build of the main table
    return Column(
      children: [
        // Header
        _buildHeader(rankWidth, teamWidth),

        // Rows
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double availableHeight = constraints.maxHeight;

              if (availableHeight < widget.teams.length * rowHeight) {
                // run the infinite table if the data can't fit
                return ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                  child: infiniteTable(rankWidth, teamWidth),
                );
              } else {
                return ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                  child: staticTable(rankWidth, teamWidth),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
