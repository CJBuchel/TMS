import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/network/auth.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/screens/selector/screen_card.dart';
import 'package:tms/screens/shared/tool_bar.dart';

class ScreenSelector extends StatefulWidget {
  const ScreenSelector({super.key});

  @override
  _ScreenSelectorState createState() => _ScreenSelectorState();
}

class _ScreenSelectorState extends State<ScreenSelector> {
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

    if (_user.permissions.admin) {
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

        // First Set of cards
        IntrinsicHeight(
          child: Row(children: [
            // Scoreboard card
            Flexible(
              flex: 1,
              child: ScreenCard(
                type: "SETUP",
                title: "Setup",
                color: const Color(0xffEDB4D0),
                textColor: const Color(0xff3F414E),
                image: const Image(
                  image: AssetImage('assets/images/FIRST_LOGO.png'),
                ),
                onPress: () {},
              ),
            ),
          ]),
        ),
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
      appBar: TmsToolBar(),
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
                      onPress: () {},
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

              ..._adminScreens
            ],
          ));
        },
      ),
    ));
  }
}
