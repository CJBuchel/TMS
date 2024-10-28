import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/user.dart';
import 'package:tms/providers/auth_provider.dart';
import 'package:tms/views/view_selector/image_button_card.dart';

class RobotGameViews extends StatelessWidget {
  const RobotGameViews({
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
              "Robot Game Views",
              style: TextStyle(
                fontSize: 28,
                color: Colors.blueGrey[800],
              ),
            ),
          ),
        ),

        Row(
          children: [
            // Referee card
            if (Provider.of<AuthProvider>(context).hasPermissionAccess(UserPermissions(referee: true)))
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: ImageButtonCard(
                    title: "Referee Scoring",
                    subTitle: "REFEREE",
                    color: const Color(0xff6CB28E),
                    textColor: const Color(0xff3F414E),
                    image: const Image(
                      image: AssetImage('assets/images/FIRST_LOGO.png'),
                    ),
                    onPressed: () {
                      context.goNamed('scoring');
                    },
                  ),
                ),
              ),
            // Head referee card
            if (Provider.of<AuthProvider>(context).hasPermissionAccess(UserPermissions(headReferee: true)))
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: ImageButtonCard(
                    title: "Match Controller",
                    subTitle: "HEAD REFEREE",
                    color: const Color(0xffD291BC),
                    textColor: const Color(0xff3F414E),
                    image: const Image(
                      image: AssetImage('assets/images/FIRST_LOGO.png'),
                    ),
                    onPressed: () {
                      context.goNamed('match_controller');
                    },
                  ),
                ),
              ),
          ],
        ),

        // Row(
        //   children: [
        //     // Announcer card
        //     if (Provider.of<AuthProvider>(context).hasPermissionAccess(UserPermissions(emcee: true, headReferee: true)))
        //       Flexible(
        //         flex: 1,
        //         child: Padding(
        //           padding: const EdgeInsets.all(10),
        //           child: ImageButtonCard(
        //             title: "Match Announcer",
        //             subTitle: "EMCEE",
        //             color: const Color(0xFF2D7F9D),
        //             textColor: const Color(0xff3F414E),
        //             image: const Image(
        //               image: AssetImage('assets/images/FIRST_LOGO.png'),
        //             ),
        //             onPressed: () {
        //               context.goNamed('match_announcer');
        //             },
        //           ),
        //         ),
        //       ),
        //   ],
        // ),
      ],
    );
  }
}
