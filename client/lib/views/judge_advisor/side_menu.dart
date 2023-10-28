import 'package:flutter/material.dart';
import 'package:tms/responsive.dart';
import 'package:tms/views/shared/dashboard/judging/judging.dart';
import 'package:tms/views/shared/dashboard/team_data/team_data.dart';
import 'package:tms/views/shared/dashboard/teams/teams.dart';
import 'package:tms/views/judge_advisor/ja_handler.dart';
import 'package:tms/views/shared/dashboard/side_menu_tile.dart';

class JudgeAdvisorSideMenu extends StatelessWidget {
  final Function(Widget view) onView;
  const JudgeAdvisorSideMenu({
    Key? key,
    required this.onView,
  }) : super(key: key);

  void _handleViewSwitch(Widget view, BuildContext context) {
    onView(view);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).canvasColor,
      width: Responsive.isDesktop(context)
          ? null
          : Responsive.isTablet(context)
              ? 250
              : 200,
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset(
              'assets/logos/TMS_LOGO_NO_TEXT.png',
            ),
          ),
          DrawerListTile(
            title: 'Judge Control',
            svgSrc: 'assets/icons/shuffle.svg',
            press: () => _handleViewSwitch(const JAHandler(), context),
          ),
          DrawerListTile(
            title: 'Judging Sessions',
            svgSrc: 'assets/icons/table.svg',
            press: () => _handleViewSwitch(const Judging(), context),
          ),
          DrawerListTile(
            title: 'Teams',
            svgSrc: 'assets/icons/teams.svg',
            press: () => _handleViewSwitch(const Teams(), context),
          ),
          DrawerListTile(
            title: 'Team Data',
            svgSrc: 'assets/icons/menu_tran.svg',
            press: () => _handleViewSwitch(const TeamData(), context),
          ),
        ],
      ),
    );
  }
}
