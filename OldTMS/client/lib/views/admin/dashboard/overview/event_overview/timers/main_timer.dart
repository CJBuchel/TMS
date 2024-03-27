import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/timer/clock.dart';

class MainTimer extends StatefulWidget {
  final double? fontSize;

  const MainTimer({
    Key? key,
    this.fontSize,
  }) : super(key: key);

  @override
  State<MainTimer> createState() => _MainTimerState();
}

class _MainTimerState extends State<MainTimer> with AutoUnsubScribeMixin, SingleTickerProviderStateMixin {
  late AnimationController _controller;

  List<String> _loadedMatches = [];

  Widget _cell({Widget? child}) {
    return Center(child: child);
  }

  set _setLoadedMatches(List<String> matches) {
    if (mounted) {
      setState(() {
        _loadedMatches = matches;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    autoSubscribe("match", (m) async {
      if (m.subTopic == "load") {
        if (m.message.isNotEmpty) {
          final jsonString = jsonDecode(m.message);
          SocketMatchLoadedMessage message = SocketMatchLoadedMessage.fromJson(jsonString);
          _setLoadedMatches = message.matchNumbers;
        }
      } else if (m.subTopic == "unload") {
        _setLoadedMatches = [];
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _getLoadedMatches() {
    if (_loadedMatches.isEmpty) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Center(
            child: Text(
              "None Loaded",
              style: TextStyle(
                fontSize: widget.fontSize,
                color: _controller.value < 0.5 ? Colors.red : Colors.grey,
              ),
            ),
          );
        },
      );
    } else {
      String matchNumbers = _loadedMatches.join(", ");
      return Center(
        child: Text(
          matchNumbers,
          style: TextStyle(
            fontSize: widget.fontSize,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // match loaded
        Expanded(
          flex: 1,
          child: _cell(
            child: Text(
              "Match:",
              style: TextStyle(fontSize: widget.fontSize),
            ),
          ),
        ),

        // match loaded
        Expanded(flex: 1, child: _getLoadedMatches()),

        // main timer
        Expanded(
          flex: 1,
          child: _cell(
            child: Clock(
              fontSize: widget.fontSize,
            ),
          ),
        ),
      ],
    );
  }
}
