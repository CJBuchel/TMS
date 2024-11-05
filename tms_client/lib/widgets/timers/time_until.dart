import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:tms/generated/infra/database_schemas/tms_time/tms_date_time.dart';
import 'package:tms/utils/tms_time_utils.dart';

class TimeUntil extends StatefulWidget {
  final TextStyle? positiveStyle;
  final String? positiveSign;
  final TextStyle? negativeStyle;
  final String? negativeSign;
  final TmsDateTime time;

  const TimeUntil({
    Key? key,
    required this.time,
    this.positiveStyle,
    this.positiveSign = '+',
    this.negativeStyle,
    this.negativeSign = '-',
  }) : super(key: key);

  @override
  State<TimeUntil> createState() => _TimeUntilState();
}

class _TimeUntilState extends State<TimeUntil> with TickerProviderStateMixin {
  Ticker? _ticker;
  ValueNotifier<int> _difference = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      _difference.value = tmsDateTimeGetDifferenceFromNow(widget.time);
    });
    _ticker!.start();
  }

  @override
  void didUpdateWidget(covariant TimeUntil oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.time != oldWidget.time) {
      _difference.value = tmsDateTimeGetDifferenceFromNow(widget.time);
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ValueListenableBuilder<int>(
        valueListenable: _difference,
        builder: (context, difference, child) {
          String timeString = secondsToTimeString(difference);
          return Text(
            difference < 0 ? "${widget.negativeSign}$timeString" : "${widget.positiveSign}$timeString",
            style: difference < 0 ? widget.negativeStyle : widget.positiveStyle,
          );
        },
      ),
    );
  }
}
