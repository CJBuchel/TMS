import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/user.dart';
import 'package:tms/providers/auth_provider.dart';
import 'package:tms/views/view_selector/image_button_card.dart';

class QueueingViews extends StatelessWidget {
  const QueueingViews({
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
              "Queueing Views",
              style: TextStyle(
                fontSize: 28,
                color: Colors.blueGrey[800],
              ),
            ),
          ),
        ),

        Row(
          children: [
            // Queueing Card
            if (Provider.of<AuthProvider>(context)
                .hasPermissionAccess(UserPermissions(queuer: true)))
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: ImageButtonCard(
                    title: "Queueing",
                    subTitle: "QUEUER",
                    // color: const Color.fromARGB(255, 189, 199, 95),
                    color: const Color.fromARGB(255, 192, 199, 95),
                    textColor: const Color(0xff3F414E),
                    image: const Image(
                      image: AssetImage('assets/images/FIRST_LOGO.png'),
                    ),
                    onPressed: () {
                      context.goNamed('queueing');
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
