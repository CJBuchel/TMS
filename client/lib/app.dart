import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/views/admin/dashboard/dashboard.dart';
import 'package:tms/views/admin/dashboard/users/users.dart';
import 'package:tms/views/admin/setup/setup.dart';
import 'package:tms/views/connection.dart';
import 'package:tms/views/judge_advisor/judge_advisor.dart';
import 'package:tms/views/judge_scoring/judge_scoring.dart';
import 'package:tms/views/match_control/match_control.dart';
import 'package:tms/views/schedule/schedule.dart';
import 'package:tms/views/scoreboard/scoreboard.dart';
import 'package:tms/views/referee_scoring/rule_book.dart';
import 'package:tms/views/referee_scoring/schedule.dart';
import 'package:tms/views/referee_scoring/referee_scoring.dart';
import 'package:tms/views/referee_scoring/table_setup.dart';
import 'package:tms/views/timer/timer.dart';
import 'package:tms/views/user/login.dart';
import 'package:tms/views/user/logout.dart';
import 'package:tms/views/selector/screen_selector.dart';

class TMSApp extends StatelessWidget {
  const TMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppTheme.isDarkTheme; // trigger getter for local storage
    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.isDarkThemeNotifier,
      builder: (context, darkThemeSelected, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'TMS Client',
          theme: ThemeData(
            brightness: brightness,
            primaryColor: primaryColor,
            scaffoldBackgroundColor: bgColor,
            secondaryHeaderColor: bgSecondaryColor,
            fontFamily: "Poppins", // our default
            // textTheme: Theme.of(context).textTheme.apply(fontFamily: "Poppins"),
            canvasColor: bgSecondaryColor,
          ),

          // Main Router
          routes: {
            '/': (context) => const ScreenSelector(),

            // Utility screens
            '/server_connection': (context) => const Connection(),
            '/login': (context) => Login(),
            '/logout': (context) => const Logout(),

            // basic screens
            '/timer': (context) => const Timer(),
            '/scoreboard': (context) => const Scoreboard(),
            '/schedule': (context) => const Schedule(),

            // admin screens
            '/admin/setup': (context) => const Setup(),
            '/admin/dashboard': (context) => const Dashboard(),
            '/admin/dashboard/users': (context) => const Users(),

            // Referee screens
            '/referee/match_control': (context) => const MatchControl(),
            '/referee/scoring': ((context) => const RefereeScoring()),
            '/referee/table_setup': (context) => const TableSetup(),
            '/referee/schedule': (context) => const RefereeSchedule(),
            '/referee/rule_book': (context) => const RuleBook(), // no good cross compatible pdf viewer

            // Judging screens
            '/judging': (context) => const JudgeScoring(),
            '/judge_advisor': (context) => const JudgeAdvisor(),
          },
        );
      },
    );
  }
}
