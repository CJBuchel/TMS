import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/network/auth.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/scoring/table_setup.dart';
import 'package:tms/views/selector/screen_card.dart';
import 'package:tms/views/shared/permissions_utils.dart';
import 'package:tms/views/shared/tool_bar.dart';

class ScreenSelector extends StatefulWidget {
  const ScreenSelector({super.key});

  @override
  State<ScreenSelector> createState() => _ScreenSelectorState();
}

/**
 * Pastel colors
 * 0xff8E97FD blue/purple
 * 0xffFFC97E yellow
 * 0xffFA6E5A red
 * 0xff6CB28E green
 * 0xffD291BC violet
 */
///

class _ScreenSelectorState extends State<ScreenSelector> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  User _user = User(password: "", permissions: Permissions(admin: false), username: "");

  void checkUser() {
    NetworkAuth.getUser().then((value) {
      setState(() {
        _user = value;
      });
    });
  }

  List<Widget> get _adminScreens {
    List<Widget> widgets = [const SizedBox.shrink()];

    if (checkPermissions(Permissions(admin: true), _user)) {
      widgets = [
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
                    fontFamily: defaultFontFamilyBold,
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
      ];
    }

    return widgets;
  }

  List<Widget> get _refereeScreens {
    List<Widget> widgets = [const SizedBox.shrink()];

    if (checkPermissions(Permissions(admin: true, headReferee: true, referee: true), _user)) {
      widgets = [
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
                    fontFamily: defaultFontFamilyBold,
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
                  title: "Scoring",
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
              if (checkPermissions(Permissions(admin: true, headReferee: true), _user))
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
      ];
    }

    return widgets;
  }

  @override
  void initState() {
    super.initState();
    checkUser();
    NetworkAuth.loginState.addListener(checkUser);
  }

  @override
  void dispose() {
    NetworkAuth.loginState.removeListener(checkUser);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: const TmsToolBar(),
      body: ValueListenableBuilder<bool>(
        valueListenable: NetworkAuth.loginState,
        builder: (context, isLoggedIn, child) {
          return (ListView(
            children: <Widget>[
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

              ..._adminScreens,
              ..._refereeScreens,
            ],
          ));
        },
      ),
    ));
  }
}
