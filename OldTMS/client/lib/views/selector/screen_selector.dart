import 'package:flutter/material.dart';
import 'package:tms/network/auth.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/selector/admin_screens.dart';
import 'package:tms/views/selector/judging_screens.dart';
import 'package:tms/views/selector/public_screens.dart';
import 'package:tms/views/selector/referee_screens.dart';
import 'package:tms/views/shared/toolbar/tool_bar.dart';

/**
 * Pastel colors
 * 0xff8E97FD blue/purple
 * 0xffFFC97E yellow
 * 0xffFA6E5A red
 * 0xff6CB28E green
 * 0xffD291BC violet
 */
///

class ScreenSelector extends StatefulWidget {
  const ScreenSelector({Key? key}) : super(key: key);

  @override
  State<ScreenSelector> createState() => _ScreenSelectorState();
}

class _ScreenSelectorState extends State<ScreenSelector> {
  final ValueNotifier<User> _userNotifier = ValueNotifier<User>(User(password: "", permissions: Permissions(admin: false), username: ""));

  @override
  void initState() {
    super.initState();
    NetworkAuth().loginState.addListener(() {
      checkUser();
    });
    checkUser();
  }

  @override
  void dispose() {
    _userNotifier.dispose();
    NetworkAuth().loginState.removeListener(() {
      checkUser();
    });
    super.dispose();
  }

  void checkUser() {
    NetworkAuth().getUser().then((value) {
      _userNotifier.value = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TmsToolBar(),
      body: ValueListenableBuilder<User>(
        valueListenable: _userNotifier,
        builder: (context, u, child) {
          return (ListView(
            children: <Widget>[
              const PublicScreens(),
              AdminScreens(user: u),
              RefereeScreens(user: u),
              JudgingScreens(user: u),
            ],
          ));
        },
      ),
    );
  }
}
