import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/tms_time/tms_date_time.dart';
import 'package:tms/utils/tms_time_utils.dart';
import 'package:tms/views/queueing/queue_card_body.dart';
import 'package:tms/widgets/timers/time_until.dart';

class QueueCard extends StatefulWidget {
  final GameMatch match;
  final bool isLoaded;
  final bool isCompleted;

  const QueueCard({
    Key? key,
    required this.match,
    required this.isLoaded,
    required this.isCompleted,
  }) : super(key: key);

  @override
  _QueueCardState createState() => _QueueCardState();
}

class _QueueCardState extends State<QueueCard>
    with SingleTickerProviderStateMixin {
  Ticker? _ticker;
  ValueNotifier<Widget> _queueStatusWidget = ValueNotifier(Container());

  Widget queueStatus() {
    DateTime matchTime = tmsDateTimeToDateTime(widget.match.startTime);
    DateTime now = DateTime.now();
    Duration difference = matchTime.difference(now);

    bool queueSoon = difference.inMinutes <= 20 && difference.inMinutes > 10;
    bool queueNow = difference.inMinutes <= 10;

    String status = "Queueing Soon";
    Color statusColor = Colors.blue;

    if (widget.isCompleted) {
      status = "CMP";
      statusColor = Colors.green;
    } else if (widget.isLoaded) {
      status = "On Deck";
      statusColor = const Color(0xFFD55C00);
    } else if (queueNow) {
      status = "Now Queueing";
      statusColor = const Color(0xFFD55C00);
    } else if (queueSoon) {
      status = "Queueing Soon";
      statusColor = Colors.blue;
    } else {
      status = "Not Queueing";
      statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      Widget statusWidget = queueStatus();
      if (statusWidget != _queueStatusWidget.value) {
        _queueStatusWidget.value = statusWidget;
      }
    });
    _ticker!.start();
  }

  @override
  void didUpdateWidget(covariant QueueCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.match != oldWidget.match ||
        widget.isLoaded != oldWidget.isLoaded ||
        widget.isCompleted != oldWidget.isCompleted) {
      _queueStatusWidget.value = queueStatus();
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  Widget ttl(TmsDateTime time, bool completed) {
    if (completed) {
      return const Text(
        'TTL: CMP',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      );
    }

    return Row(
      children: [
        const Text(
          'TTL: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        TimeUntil(
          time: time,
          positiveStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.green,
          ),
          negativeStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.red,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color crossOutColor = isDarkMode ? Colors.white : Colors.black;

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 35.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).cardColor,
            border: Border.all(color: Colors.black),
          ),
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    ttl(widget.match.startTime, widget.match.completed),
                    const Spacer(),
                    ValueListenableBuilder<Widget>(
                      valueListenable: _queueStatusWidget,
                      builder: (context, value, child) {
                        return value;
                      },
                    ),
                  ],
                ),
              ),

              // Main body
              QueueCardBody(
                match: widget.match,
                isLoaded: widget.isLoaded,
                isCompleted: widget.isCompleted,
              ),
            ],
          ),
        ),
        if (widget.isCompleted)
          Positioned.fill(
            child: Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 35.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: CrossOutPainter(color: crossOutColor),
              ),
            ),
          ),
      ],
    );
  }
}

class CrossOutPainter extends CustomPainter {
  final Color color;

  CrossOutPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Draw diagonal lines from corners
    canvas.drawLine(
      Offset.zero,
      Offset(size.width, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(0, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
