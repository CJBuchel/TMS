import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/sorter_util.dart';

class MatchInfoTable extends StatefulWidget {
  final Event? event;
  final List<GameMatch> matches;
  final List<Team> teams;
  const MatchInfoTable({
    Key? key,
    required this.event,
    required this.matches,
    required this.teams,
  }) : super(key: key);

  @override
  State<MatchInfoTable> createState() => _MatchInfoTableState();
}

class _MatchInfoTableState extends State<MatchInfoTable> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  final int _scrollSpeed = 25;
  final double _mainCellWidth = 400; // i'll probably change this later

  late AnimationController _animationController;
  late ScrollController _scrollController;
  bool _animationHasBeenInitialized = false;

  void initializeInfiniteAnimation() {
    if ((widget.event?.tables.isNotEmpty ?? false) && !_animationHasBeenInitialized) {
      _animationHasBeenInitialized = true;
      _animationController = AnimationController(
        vsync: this,
        duration: Duration(seconds: (widget.event?.tables.isEmpty ?? true ? 1 : widget.event!.tables.length) * _scrollSpeed),
      )
        ..addListener(() {
          double resetPosition = (widget.event?.pods.length ?? 0) * _mainCellWidth; // position where the second table starts
          double currentScroll = _animationController.value * resetPosition * 2; // scroll through double the data

          if (currentScroll >= resetPosition && _scrollController.hasClients && (widget.event?.tables.isNotEmpty ?? false)) {
            _animationController.forward(from: 0.0);
          } else {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(currentScroll);
            }
          }
        })
        ..repeat();
    }
  }

  @override
  void didUpdateWidget(covariant MatchInfoTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      if (widget.event?.tables.length != oldWidget.event?.tables.length) {
        if (!_animationHasBeenInitialized) {
          initializeInfiniteAnimation();
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    initializeInfiniteAnimation();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (_animationHasBeenInitialized) {
      _animationController.dispose();
    }
    super.dispose();
  }

  Widget _buildTextCell(String text, {double? width}) {
    return SizedBox(
      width: width,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildRow(List<Team> teams, GameMatch match, Color rowColor, double rowHeight, double rowWidth) {
    double cellWidth = 300;
    return Container(
        height: rowHeight,
        width: rowWidth,
        color: rowColor,
        child: Row(
          children: [
            // start time
            _buildTextCell(
              match.startTime,
              width: cellWidth,
            ),

            LayoutBuilder(
              builder: (context, constraints) {
                double availableWidth = rowWidth - cellWidth; // max width - start time width
                if (availableWidth < match.matchTables.length * _mainCellWidth) {
                  return SizedBox(
                    width: rowWidth - cellWidth,
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: match.matchTables.length,
                      itemBuilder: (context, index) {
                        Team? team;
                        for (var t in teams) {
                          if (t.teamNumber == match.matchTables[index].teamNumber) {
                            team = t;
                          }
                        }

                        return SizedBox(
                          width: _mainCellWidth,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              team != null ? "${team.teamNumber} | ${team.teamName} | Table ${match.matchTables[index]} " : "",
                              style: const TextStyle(
                                color: Colors.black,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return SizedBox(
                    width: rowWidth - cellWidth,
                    child: Row(
                      children: match.matchTables.expand((table) {
                        Team? team;
                        for (var t in teams) {
                          if (t.teamNumber == table.teamNumber) {
                            team = t;
                          }
                        }
                        return [
                          // team cell
                          Expanded(
                            child: _buildTextCell(
                              team != null ? "${team.teamNumber} | ${team.teamName} | Table ${table.table}" : "",
                              width: _mainCellWidth,
                            ),
                          ),
                        ];
                      }).toList(),
                    ),
                  );
                }
              },
            ),
          ],
        ));
  }

  Widget getMatchInfo() {
    List<GameMatch> futureMatches = [];
    for (var match in widget.matches) {
      if (!match.complete) {
        futureMatches.add(match);
      }
    }
    futureMatches = sortMatchesByTime(futureMatches);

    int itemCount = 3;
    return LayoutBuilder(builder: ((context, constraints) {
      if (futureMatches.isEmpty || widget.teams.isEmpty) {
        return Container(
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          color: Colors.white,
          child: const Center(
            child: Text(
              "No Matches",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
        );
      } else {
        return SizedBox(
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (index >= futureMatches.length) {
                return Container(
                  height: constraints.maxHeight / itemCount,
                  width: constraints.maxWidth,
                  color: index.isEven ? Colors.white : Colors.grey[300],
                );
              } else {
                return _buildRow(
                  widget.teams,
                  futureMatches[index],
                  index.isEven ? Colors.white : Colors.grey[300]!,
                  constraints.maxHeight / itemCount,
                  constraints.maxWidth,
                );
              }
            },
          ),
        );
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return getMatchInfo();
  }
}
