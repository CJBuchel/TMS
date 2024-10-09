import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tms/views/view_selector/image_button_card.dart';

class AdminViews extends StatelessWidget {
  const AdminViews({
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
              "Admin Views",
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
                  title: "Setup",
                  subTitle: "ADMIN",
                  color: const Color(0xffFA6E5A),
                  textColor: const Color(0xff3F414E),
                  image: const Image(
                    image: AssetImage('assets/images/FIRST_LOGO.png'),
                  ),
                  onPressed: () {
                    context.goNamed('setup');
                  },
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ImageButtonCard(
                  title: "Dashboard",
                  subTitle: "ADMIN",
                  color: const Color(0xff2ACAC8),
                  textColor: const Color(0xff3F414E),
                  image: const Image(
                    image: AssetImage('assets/images/FIRST_LOGO.png'),
                  ),
                  onPressed: () {
                    context.goNamed('dashboard');
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
