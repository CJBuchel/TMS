import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tms/views/view_selector/image_button_card.dart';

class PublicViews extends StatelessWidget {
  const PublicViews({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(top: 40, left: 10, right: 10),
            child: Text(
              "Public Screens",
              style: TextStyle(
                fontSize: 28,
                color: Colors.blueGrey[800],
              ),
            ),
          ),
        ),

        // setup car
        Row(
          children: [
            // Setup card
            Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ImageButtonCard(
                  title: "Timer",
                  subTitle: "PUBLIC",
                  color: const Color(0xffFFC97E),
                  textColor: const Color(0xff3F414E),
                  image: const Image(
                    image: AssetImage('assets/images/FIRST_LOGO.png'),
                  ),
                  onPressed: () {
                    context.go('/game_match_timer');
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
