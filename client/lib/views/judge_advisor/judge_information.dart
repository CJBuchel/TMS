import 'package:flutter/material.dart';

class JudgeInformation extends StatefulWidget {
  const JudgeInformation({Key? key}) : super(key: key);

  @override
  State<JudgeInformation> createState() => _JudgeInformationState();
}

class _JudgeInformationState extends State<JudgeInformation> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        height: constraints.maxHeight,
        width: constraints.maxWidth,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.blueGrey[600],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: null,
              ),
            ),
          ],
        ),
      );
    });
  }
}
