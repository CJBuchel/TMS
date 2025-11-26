import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/utils/color_modifiers.dart';
import 'package:tms/views/queueing/check_in_segment.dart';

class QueueCardBody extends StatefulWidget {
  final GameMatch match;
  final bool isLoaded;
  final bool isCompleted;

  const QueueCardBody({
    Key? key,
    required this.match,
    required this.isLoaded,
    required this.isCompleted,
  }) : super(key: key);

  @override
  _QueueCardBodyState createState() => _QueueCardBodyState();
}

class _QueueCardBodyState extends State<QueueCardBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();

    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  List<Widget> bodyContent(
    List<GameMatchTable> tables,
    Color bgColor,
    bool isLoaded,
    String matchNumber,
    bool isRowLayout,
  ) {
    return tables.map((t) {
      final checkInSegment = CheckInSegment(
        matchNumber: matchNumber,
        table: t,
        isLoaded: isLoaded,
      );

      final animatedBuilder = AnimatedBuilder(
        animation: _blinkController,
        child: checkInSegment,
        builder: (context, child) {
          Color containerColor = bgColor;
          bool notCheckedIn = t.checkInStatus == TeamCheckInStatus.notCheckedIn;

          if (notCheckedIn && isLoaded) {
            containerColor = isLoaded
                ? Color.lerp(
                      Colors.red,
                      bgColor,
                      _blinkController.value,
                    ) ??
                    bgColor
                : bgColor;
          }

          return Container(
            margin: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 8.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: containerColor,
              border: Border.all(color: Colors.black),
            ),
            child: child,
          );
        },
      );

      // Wrap in Flexible for Row layout
      if (isRowLayout) {
        return Flexible(child: animatedBuilder);
      }
      return animatedBuilder;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    bool allCheckedIn = widget.match.gameMatchTables.every((table) {
      return table.checkInStatus == TeamCheckInStatus.checkedIn ||
          table.checkInStatus == TeamCheckInStatus.notPlaying;
    });

    Color statusColor = (widget.isCompleted || allCheckedIn)
        ? Colors.green
        : (widget.isLoaded ? const Color(0xFFD55C00) : Colors.grey);

    return Container(
      decoration: BoxDecoration(
        // border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).cardColor,
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          width: 100,
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Match Number
              Text(
                '#${widget.match.matchNumber}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              // Time
              Text(
                widget.match.startTime.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              Color bgColor = lighten(Theme.of(context).cardColor);
              bool isRowLayout = constraints.maxWidth >= 500;
              final children = bodyContent(
                widget.match.gameMatchTables,
                bgColor,
                widget.isLoaded,
                widget.match.matchNumber,
                isRowLayout,
              );

              if (isRowLayout) {
                return Row(children: children);
              } else {
                return Wrap(children: children);
              }
            },
          ),
        )
      ]),
    );
  }
}
