import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/schema/tms_schema.dart';

class MatchLoadedTable extends StatefulWidget {
  final bool? autoRowColors;
  final List<Team> teams;
  final List<OnTable> tables;
  const MatchLoadedTable({
    Key? key,
    this.autoRowColors,
    required this.teams,
    required this.tables,
  }) : super(key: key);

  @override
  State<MatchLoadedTable> createState() => _MatchLoadedTableState();
}

class _MatchLoadedTableState extends State<MatchLoadedTable> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  final double _tableWidth = 100;
  final double _headerHeight = 24;
  final double _rowHeight = 48;

  final int _scrollSpeed = 5;
  late ScrollController _scrollController;
  late AnimationController _animationController;

  bool _animationHasBeenInitialized = false;
  bool _nthSwitch = false;

  void toggleNth() {
    setState(() {
      _nthSwitch = !_nthSwitch;
    });
  }

  List<OnTable> _tables = [];

  void initializeInfiniteAnimation() {
    if (_tables.isNotEmpty) {
      _animationHasBeenInitialized = true;

      _animationController = AnimationController(
        vsync: this,
        duration: Duration(seconds: (_tables.isEmpty ? 1 : _tables.length) * _scrollSpeed),
      )
        ..addListener(() {
          double resetPosition = _tables.length * _rowHeight; // Position where the second table starts
          double currentScroll = _animationController.value * resetPosition * 2; // Scrolling through double the data

          if (currentScroll >= resetPosition && _scrollController.hasClients && _tables.isNotEmpty) {
            if (_tables.length.isOdd) {
              toggleNth();
            }
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
  void didUpdateWidget(covariant MatchLoadedTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget != oldWidget) {
      if (!listEquals(_tables, widget.tables)) {
        setState(() {
          _tables = widget.tables;
          if (!_animationHasBeenInitialized) {
            initializeInfiniteAnimation();
          }
        });
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

  Widget _buildCell(String text, {Color? backgroundColor, Color? textColor, double? width}) {
    return Container(
      width: width,
      color: backgroundColor,
      child: Center(child: Text(text, style: TextStyle(color: textColor, overflow: TextOverflow.ellipsis))),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black,
            width: 1,
          ),
        ),
      ),
      height: _headerHeight,
      child: Row(
        children: [
          _buildCell("On Table", width: _tableWidth, textColor: Colors.white, backgroundColor: Colors.blueGrey[800]),
          Expanded(child: _buildCell("Team", textColor: Colors.white, backgroundColor: Colors.blueGrey[800])),
        ],
      ),
    );
  }

  Widget _buildRow(List<Team> teams, OnTable table, Color rowColor) {
    // find team related to on table
    Team? tmpTeam;

    // find team related to on table
    for (var team in teams) {
      if (team.teamNumber == table.teamNumber) {
        tmpTeam = team;
      }
    }

    Color textColor = widget.autoRowColors ?? false ? (AppTheme.isDarkTheme ? Colors.white : Colors.black) : Colors.black;

    return Container(
      decoration: BoxDecoration(
        color: rowColor,
        border: const Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
      ),
      height: _rowHeight,
      child: Row(
        children: [
          _buildCell(table.table, width: _tableWidth, textColor: textColor),
          Expanded(
            child: _buildCell(
              tmpTeam != null ? "${tmpTeam.teamNumber} | ${tmpTeam.teamName}" : "",
              textColor: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget infiniteTable() {
    // build list view
    return ListView.builder(
      controller: _scrollController,
      itemCount: _tables.length * 2,
      itemBuilder: (context, index) {
        bool isNth = (_nthSwitch ? index.isEven : index.isOdd);
        Color regularRowColor = (_nthSwitch ? index.isEven : index.isOdd) ? Colors.white : const Color.fromARGB(255, 218, 218, 218);
        Color autoRowColor = isNth ? Theme.of(context).colorScheme.secondary.withOpacity(0.1) : Theme.of(context).splashColor;
        Color rowColor = widget.autoRowColors ?? false ? autoRowColor : regularRowColor;
        return _buildRow(
          widget.teams,
          _tables[index % _tables.length],
          rowColor,
        );
      },
    );
  }

  Widget staticTable() {
    return ListView.builder(
      itemCount: _tables.length,
      itemBuilder: (context, index) {
        bool isNth = (_nthSwitch ? index.isEven : index.isOdd);
        Color regularRowColor = (_nthSwitch ? index.isEven : index.isOdd) ? Colors.white : const Color.fromARGB(255, 218, 218, 218);
        Color autoRowColor = isNth ? Theme.of(context).colorScheme.secondary.withOpacity(0.1) : Theme.of(context).splashColor;
        Color rowColor = widget.autoRowColors ?? false ? autoRowColor : regularRowColor;
        return _buildRow(
          widget.teams,
          _tables[index],
          rowColor,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        _buildHeader(),

        // main team rows
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double availableHeight = constraints.maxHeight;

              if (availableHeight < _tables.length * _rowHeight) {
                return ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                  child: infiniteTable(),
                );
              } else {
                return ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                  child: staticTable(),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
