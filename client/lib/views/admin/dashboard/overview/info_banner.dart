import 'package:flutter/material.dart';
import 'package:tms/constants.dart';

class OverviewInfoBanner extends StatelessWidget {
  const OverviewInfoBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text("Test 1"),
        Text("Test 2"),
      ],
    );
  }
}
