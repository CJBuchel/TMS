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
        IntrinsicHeight(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 40, 0, 0),
              child: Text(
                "Admin Screens",
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.blueGrey[800],
                ),
              ),
            ),
          ),
        ),

        // setup car
        IntrinsicHeight(
          child: Row(
            children: [
              // Setup card
              Flexible(
                flex: 1,
                child: ImageButtonCard(
                  title: "Setup",
                  subTitle: "ADMIN",
                  color: const Color(0xffFA6E5A),
                  textColor: const Color(0xff3F414E),
                  image: const Image(
                    image: AssetImage('assets/images/FIRST_LOGO.png'),
                  ),
                  onPressed: () {
                    context.go('/setup');
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
