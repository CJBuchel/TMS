import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tms/constants.dart';
import 'package:tms/responsive.dart';
import 'package:tms/views/admin/dashboard/matches/matches.dart';
import 'package:tms/views/admin/dashboard/overview/overview.dart';
import 'package:tms/views/admin/dashboard/users/users.dart';

class DrawerListTile extends StatelessWidget {
  final String title, svgSrc;
  final VoidCallback press;
  const DrawerListTile({
    Key? key,
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: ColorFilter.mode(AppTheme.isDarkTheme ? Colors.white54 : Colors.black, BlendMode.srcIn),
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(color: AppTheme.isDarkTheme ? Colors.white54 : Colors.black),
      ),
    );
  }
}

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
            title: 'Teams',
            svgSrc: 'assets/icons/teams.svg',
            press: () {},
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
