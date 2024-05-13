import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tms/views/view_selector/image_button_card.dart';

class RefereeViews extends StatelessWidget {
  const RefereeViews({
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
              "Referee Screens",
              style: TextStyle(
                fontSize: 28,
                color: Colors.blueGrey[800],
              ),
            ),
          ),
        ),

        Row(
          children: [
            // Setup card
            Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ImageButtonCard(
                  title: "Match Controller",
                  subTitle: "HEAD REFEREE",
                  color: const Color(0xffFA6E5A),
                  textColor: const Color(0xff3F414E),
                  image: const Image(
                    image: AssetImage('assets/images/FIRST_LOGO.png'),
                  ),
                  onPressed: () {
                    context.go('/referee/match_controller');
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
