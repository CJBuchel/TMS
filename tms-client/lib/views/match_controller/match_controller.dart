import 'package:flutter/material.dart';
import 'package:tms/views/match_controller/mtach_table.dart';

class MatchController extends StatelessWidget {
  const MatchController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          flex: 1,
          child: Center(
            child: Text("Left"),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(child: MatchTable()),
        ),
      ],
    );
  }
}
