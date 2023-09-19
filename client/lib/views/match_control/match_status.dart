import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:tms/responsive.dart';

class MatchStatus extends StatefulWidget {
  final bool isLoaded;
  const MatchStatus({Key? key, required this.isLoaded}) : super(key: key);

  @override
  State<MatchStatus> createState() => _MatchStatusState();
}

class _MatchStatusState extends State<MatchStatus> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget getStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Status: ",
          style: TextStyle(
            fontSize: Responsive.isDesktop(context) ? 35 : 25,
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            if (widget.isLoaded) {
              return Text(
                "Match Loaded",
                style: TextStyle(
                  fontSize: Responsive.isDesktop(context) ? 35 : 25,
                  color: Colors.orange,
                ),
              );
            } else {
              return Text(
                "No Match Loaded",
                style: TextStyle(
                  fontSize: Responsive.isDesktop(context) ? 35 : 25,
                  color: _controller.value < 0.5 ? Colors.red : Colors.grey,
                ),
              );
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return getStatus();
  }
}
