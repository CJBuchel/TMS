import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/permissions_utils.dart';
import 'package:tms/views/selector/screen_card.dart';

class JudgingScreens extends StatefulWidget {
  final User user;
  const JudgingScreens({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<JudgingScreens> createState() => _JudgingScreensState();
}

class _JudgingScreensState extends State<JudgingScreens> {
  @override
  Widget build(BuildContext context) {
    if (checkPermissions(Permissions(admin: true, judgeAdvisor: true, judge: true), widget.user)) {
      return Column(
        children: [
          // Judging Title
          IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 40, 0, 0),
                  child: Text(
                    "Judging Screens",
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.blueGrey[800],
                      fontFamily: defaultFontFamilyBold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Judging Screen cards
          IntrinsicHeight(
            child: Row(
              children: [
                // Judging card
                Flexible(
                  flex: 1,
                  child: ScreenCard(
                    type: "JUDGING",
                    title: "Judge Scoring",
                    color: const Color(0xff93C6E7),
                    textColor: const Color(0xff3F414E),
                    image: const Image(
                      image: AssetImage('assets/images/FIRST_LOGO.png'),
                    ),
                    onPress: () {
                      Navigator.pushNamed(context, '/judging');
                    },
                  ),
                ),

                // Judging Dashboard card
                Flexible(
                  flex: 1,
                  child: ScreenCard(
                    type: "JUDGING",
                    title: "Judge Advisor",
                    color: const Color(0xFF828282),
                    textColor: const Color(0xff3F414E),
                    image: const Image(
                      image: AssetImage('assets/images/FIRST_LOGO.png'),
                    ),
                    onPress: () {
                      Navigator.pushNamed(context, '/judge_advisor');
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
