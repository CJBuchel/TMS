import 'package:flutter/material.dart';
import 'package:tms/views/match_controller/match_table.dart';

class MatchController extends StatelessWidget {
  const MatchController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          flex: 1,
          child: Center(
            child: Text("Left"),
          ),
        ),
        Expanded(
          flex: 1,
          child: FutureBuilder(
            future: Future.delayed(const Duration(milliseconds: 500)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }
              return const MatchTable();
            },
          ),
        ),
      ],
    );
  }
}
