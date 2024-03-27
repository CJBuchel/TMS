import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/permissions_utils.dart';
import 'package:tms/views/selector/screen_card.dart';

class AdminScreens extends StatelessWidget {
  final User user;
  const AdminScreens({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (checkPermissions(Permissions(admin: true), user)) {
      return Column(
        children: [
          // Admin Title
          IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 40, 0, 0),
                  child: Text(
                    "Admin Screens",
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Admin Setup Cards
          IntrinsicHeight(
            child: Row(
              children: [
                // Setup card
                Flexible(
                  flex: 1,
                  child: ScreenCard(
                    type: "ADMIN",
                    title: "Setup",
                    color: const Color(0xffFA6E5A),
                    textColor: const Color(0xff3F414E),
                    image: const Image(
                      image: AssetImage('assets/images/FIRST_LOGO.png'),
                    ),
                    onPress: () {
                      Navigator.pushNamed(context, '/admin/setup');
                    },
                  ),
                ),

                // Dashboard card
                Flexible(
                  flex: 1,
                  child: ScreenCard(
                    type: "ADMIN",
                    title: "Dashboard",
                    color: const Color(0xff2ACAC8),
                    textColor: const Color(0xff3F414E),
                    image: const Image(
                      image: AssetImage('assets/images/FIRST_LOGO.png'),
                    ),
                    onPress: () {
                      Navigator.pushNamed(context, '/admin/dashboard');
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
