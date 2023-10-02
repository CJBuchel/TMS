import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multiselect/multiselect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/constants.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';

class TimerTableListenerUtil {
  static final Future<SharedPreferences> _localStorage = SharedPreferences.getInstance();

  static Future<void> setTableListeners(List<String> listeners) async {
    await _localStorage.then((value) => value.setStringList(storeTimerTableListeners, listeners));
  }

  static Future<List<String>> getTableListeners() async {
    try {
      var listeners = await _localStorage.then((value) => value.getStringList(storeTimerTableListeners));
      if (listeners != null) {
        return listeners;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}

class TimerHeader extends StatefulWidget {
  final Event? event;
  final List<GameMatch> matches;
  final List<GameMatch> loadedMatches;
  final Function(List<String>) onTableListenerChanged;
  const TimerHeader({
    Key? key,
    required this.event,
    required this.matches,
    required this.loadedMatches,
    required this.onTableListenerChanged,
  }) : super(key: key);

  @override
  State<TimerHeader> createState() => _TimerHeaderState();
}

class _TimerHeaderState extends State<TimerHeader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  List<String> _tableOptions = [];
  List<String> _tableListeners = [];

  void setTableListeners(List<String> listeners) {
    TimerTableListenerUtil.setTableListeners(listeners);
    _tableListeners = listeners;
    widget.onTableListenerChanged(listeners);
  }

  String getMatchNumbers(List<GameMatch> matches) {
    return matches.map((m) => m.matchNumber.toString()).join(", ");
  }

  Widget getLoadedMatches() {
    if (widget.loadedMatches.isEmpty) {
      return AnimatedBuilder(
        animation: _controller,
        builder: ((context, child) {
          return Center(
            child: Text(
              'No Matches Loaded',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Responsive.isDesktop(context) ? 35 : 25,
                color: _controller.value < 0.5 ? Colors.red : Colors.grey,
              ),
            ),
          );
        }),
      );
    } else {
      String matchNumbers = getMatchNumbers(widget.loadedMatches);
      return Center(
        child: Text(
          "Match: $matchNumbers",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: Responsive.isDesktop(context) ? 35 : 25,
          ),
        ),
      );
    }
  }

  @override
  void didUpdateWidget(covariant TimerHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget != oldWidget) {
      if (widget.event != null) {
        TimerTableListenerUtil.getTableListeners().then((value) {
          if (value.isEmpty) {
            setTableListeners(widget.event!.tables);
          } else {
            setTableListeners(value);
          }
        });
        setState(() {
          _tableOptions = widget.event!.tables;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    if (widget.event != null) {
      setState(() {
        _tableOptions = widget.event!.tables;
      });
    }

    TimerTableListenerUtil.getTableListeners().then((value) {
      if (value.isEmpty) {
        setTableListeners(_tableOptions);
      } else {
        setTableListeners(value);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    width: 1,
                    color: AppTheme.isDarkTheme ? Colors.white : Colors.black,
                  ),
                ),
              ),
              width: constraints.maxWidth / 2,
              child: getLoadedMatches(),
            ),
            SizedBox(
              width: constraints.maxWidth / 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Center(
                  child: DropDownMultiSelect(
                    onChanged: (List<String> x) {
                      setTableListeners(x);
                    },
                    options: _tableOptions,
                    selectedValues: _tableListeners,
                    whenEmpty: "Select Listeners",
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
