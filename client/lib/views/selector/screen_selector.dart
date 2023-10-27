import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/network/auth.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/selector/admin_screens.dart';
import 'package:tms/views/selector/judging_screens.dart';
import 'package:tms/views/selector/public_screens.dart';
import 'package:tms/views/selector/referee_screens.dart';
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
              const PublicScreens(),
              AdminScreens(user: _user),
              RefereeScreens(user: _user),
              JudgingScreens(user: _user),
            ],
          ));
        },
      ),
    ));
  }
}
