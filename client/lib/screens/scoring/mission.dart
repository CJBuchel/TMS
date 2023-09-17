import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/screens/shared/network_image.dart';

class MissionWidget extends StatelessWidget {
  final Mission mission;
  final List<Score> scores;
  late NetworkImageWidget _image;

  MissionWidget({Key? key, required this.mission, required this.scores}) : super(key: key) {
    _image = NetworkImageWidget(
      src: mission.image ?? "",
      width: 150,
      height: 150,
      defaultImage: const AssetImage('assets/images/FIRST_LOGO.png'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _image,
          ...scores.map((score) => Text(score.label)),
        ],
      ),
    );
  }
}
