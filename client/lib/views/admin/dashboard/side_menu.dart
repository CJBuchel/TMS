import 'package:flutter/material.dart';
import 'package:tms/responsive.dart';
import 'package:tms/views/admin/dashboard/backups/backups.dart';
import 'package:tms/views/shared/dashboard/judging/judging.dart';
import 'package:tms/views/shared/dashboard/matches/matches.dart';
import 'package:tms/views/admin/dashboard/overview/overview.dart';
import 'package:tms/views/shared/dashboard/pods/pods.dart';
import 'package:tms/views/shared/dashboard/tables/tables.dart';
import 'package:tms/views/shared/dashboard/team_data/team_data.dart';
import 'package:tms/views/shared/dashboard/teams/teams.dart';
import 'package:tms/views/admin/dashboard/users/users.dart';
import 'package:tms/views/shared/dashboard/side_menu_tile.dart';

class SideMenu extends StatelessWidget {
  final Function(Widget view) onView;
  const SideMenu({Key? key, required this.onView}) : super(key: key);

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
            title: 'Overview',
            svgSrc: 'assets/icons/menu_dashboard.svg',
            press: () => _handleViewSwitch(const Overview(), context),
          ),
          DrawerListTile(
            title: 'Users',
            svgSrc: 'assets/icons/menu_profile.svg',
            press: () => _handleViewSwitch(const Users(), context),
          ),
          DrawerListTile(
            title: 'Matches',
            svgSrc: 'assets/icons/table.svg',
            press: () => _handleViewSwitch(const Matches(), context),
          ),
          DrawerListTile(
            title: 'Tables',
            icon: Icons.table_restaurant,
            press: () => _handleViewSwitch(const Tables(), context),
          ),
          DrawerListTile(
            title: 'Judging',
            svgSrc: 'assets/icons/table.svg',
            press: () => _handleViewSwitch(const Judging(), context),
          ),
          DrawerListTile(
            title: 'Pods',
            icon: Icons.table_bar_rounded,
            press: () => _handleViewSwitch(const Pods(), context),
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
          DrawerListTile(
            title: 'Backups',
            icon: Icons.backup_outlined,
            press: () => _handleViewSwitch(const Backups(), context),
          ),
        ],
      ),
    );
  }
}
