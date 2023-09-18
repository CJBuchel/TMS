import 'package:flutter/material.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/screens/scoring/question.dart';
import 'package:tms/screens/shared/network_image.dart';

class MissionWidget extends StatelessWidget {
  final Mission mission;
  final List<Score> scores;
  final Color? color;
  late NetworkImageWidget _image;

  MissionWidget({Key? key, required this.mission, required this.scores, this.color}) : super(key: key) {
    _image = NetworkImageWidget(
      src: mission.image ?? "",
      width: 160,
      height: 90,
      borderRadius: 10,
      defaultImage: const AssetImage('assets/images/FIRST_LOGO.png'),
    );
  }

  Widget getMissionHeader(BuildContext context) {
    if (!Responsive.isMobile(context)) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: _image,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              mission.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              mission.title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: _image,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getMissionHeader(context),
          ...scores.map((score) => QuestionWidget(score: score)),
        ],
      ),
    );
  }
}
