import 'package:flutter/material.dart';
import 'package:tms/responsive.dart';
import 'package:tms/views/admin/dashboard/judging/judging.dart';
import 'package:tms/views/shared/dashboard/matches/matches.dart';
import 'package:tms/views/admin/dashboard/overview/overview.dart';
import 'package:tms/views/admin/dashboard/teams/teams.dart';
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
            title: 'Judging',
            svgSrc: 'assets/icons/table.svg',
            press: () => _handleViewSwitch(const Judging(), context),
          ),
          DrawerListTile(
            title: 'Teams',
            svgSrc: 'assets/icons/teams.svg',
            press: () => _handleViewSwitch(Teams(), context),
          ),
          // DrawerListTile(
          //   title: 'Documents',
          //   svgSrc: 'assets/icons/menu_doc.svg',
          //   press: () {},
          // ),
          // DrawerListTile(
          //   title: 'Store',
          //   svgSrc: 'assets/icons/menu_store.svg',
          //   press: () {},
          // ),
          // DrawerListTile(
          //   title: 'Notification',
          //   svgSrc: 'assets/icons/menu_notification.svg',
          //   press: () {},
          // ),
          // DrawerListTile(
          //   title: 'Settings',
          //   svgSrc: 'assets/icons/menu_setting.svg',
          //   press: () {},
          // ),
        ],
      ),
    );
  }
}
