import 'package:flutter/material.dart';
import 'package:tms/views/match_controller/match_selector/match_selection.dart';
import 'package:tms/widgets/animated/barber_pole_container.dart';

class MatchController extends StatelessWidget {
  const MatchController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Center(
            child: BarberPoleContainer(
              active: true,
              width: 100,
              height: 100,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
              child: const Center(
                child: Text("hello"),
              ),
            ),
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
              return MatchSelection();
            },
          ),
        ),
      ],
    );
  }
}
