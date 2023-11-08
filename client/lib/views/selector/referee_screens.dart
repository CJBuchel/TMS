import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/permissions_utils.dart';
import 'package:tms/views/referee_scoring/table_setup.dart';
import 'package:tms/views/selector/screen_card.dart';

class RefereeScreens extends StatefulWidget {
  final User user;
  const RefereeScreens({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<RefereeScreens> createState() => _RefereeScreensState();
}

class _RefereeScreensState extends State<RefereeScreens> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  @override
  Widget build(BuildContext context) {
    if (checkPermissions(Permissions(admin: true, headReferee: true, referee: true), widget.user)) {
      return Column(
        children: [
          // Referee Title
          IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 40, 0, 0),
                  child: Text(
                    "Referee Screens",
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Referee Screen cards
          IntrinsicHeight(
            child: Row(
              children: [
                // Scoring card
                Flexible(
                  flex: 1,
                  child: ScreenCard(
                    type: "REFEREE",
                    title: "Referee Scoring",
                    color: const Color(0xff6CB28E),
                    textColor: const Color(0xff3F414E),
                    image: const Image(
                      image: AssetImage('assets/images/FIRST_LOGO.png'),
                    ),
                    onPress: () {
                      RefereeTableUtil.getTable().then((table) {
                        getEvent().then((event) {
                          if (table.isEmpty || !event.tables.contains(table)) {
                            Navigator.pushNamed(context, '/referee/table_setup');
                          } else {
                            Navigator.pushNamed(context, '/referee/scoring');
                          }
                        });
                      });
                    },
                  ),
                ),

                // Head Referee card
                if (checkPermissions(Permissions(admin: true, headReferee: true), widget.user))
                  Flexible(
                    flex: 1,
                    child: ScreenCard(
                      type: "HEAD REFEREE",
                      title: "Match Control",
                      color: const Color(0xffD291BC),
                      textColor: const Color(0xff3F414E),
                      image: const Image(
                        image: AssetImage('assets/images/FIRST_LOGO.png'),
                      ),
                      onPress: () {
                        Navigator.pushNamed(context, '/referee/match_control');
                      },
                    ),
                  ),
              ],
            ),
          )
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
