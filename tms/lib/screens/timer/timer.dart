import 'package:flutter/material.dart';
import 'package:tms/screens/shared/tool_bar.dart';
import 'package:tms/screens/timer/clock.dart';
import 'package:tms/responsive.dart';

class Timer extends StatelessWidget {
  const Timer({super.key});

  void testTimerController(BuildContext context) async {}

  @override
  Widget build(BuildContext context) {
    var imageSize = <double>[300, 500];
    double buttonWidth = 250;
    double buttonHeight = 50;
    if (Responsive.isTablet(context)) {
      imageSize = [150, 300];
      buttonWidth = 200;
    } else if (Responsive.isMobile(context)) {
      imageSize = [100, 250];
      buttonWidth = 150;
      buttonHeight = 40;
    }

    return Scaffold(
        appBar: TmsToolBar(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Clock
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Clock(),
              ],
            ),

            // Start button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton.icon(
                    onPressed: () => {},
                    icon: const Icon(Icons.login),
                    label: const Text("Start"),
                  ),
                )
              ],
            )
          ],
        ));
  }
}
