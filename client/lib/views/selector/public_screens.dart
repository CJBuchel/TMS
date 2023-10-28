import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/views/selector/screen_card.dart';

class PublicScreens extends StatelessWidget {
  const PublicScreens({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Public Title
        IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 40, 0, 0),
                child: Text(
                  "Public Screens",
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

        // First Set of cards
        IntrinsicHeight(
          child: Row(children: [
            // Scoreboard card
            Flexible(
              flex: 1,
              child: ScreenCard(
                type: "BASIC",
                title: "Scoreboard",
                color: const Color(0xff8E97FD),
                textColor: const Color(0xff3F414E),
                image: const Image(
                  image: AssetImage('assets/images/FIRST_LOGO.png'),
                ),
                onPress: () {
                  Navigator.pushNamed(context, '/scoreboard');
                },
              ),
            ),

            // Timer card
            Flexible(
              flex: 1,
              fit: FlexFit.loose,
              child: ScreenCard(
                type: "BASIC",
                title: "Timer",
                color: const Color(0xffFFC97E),
                textColor: const Color(0xff3F414E),
                image: const Image(
                  image: AssetImage('assets/images/FIRST_LOGO.png'),
                ),
                onPress: () {
                  Navigator.pushNamed(context, '/timer');
                },
              ),
            ),
          ]),
        ),

        // second set of screens
        IntrinsicHeight(
          child: Row(children: [
            // Scoreboard card
            Flexible(
              flex: 1,
              child: ScreenCard(
                type: "BASIC",
                title: "Schedule",
                color: const Color(0xFF00617A),
                textColor: const Color(0xFFFFFFFF),
                image: const Image(
                  image: AssetImage('assets/images/FIRST_LOGO.png'),
                ),
                onPress: () {
                  Navigator.pushNamed(context, '/schedule');
                },
              ),
            ),
          ]),
        ),
      ],
    );
  }
}
