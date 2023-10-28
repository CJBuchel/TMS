import 'package:flutter/material.dart';
import 'package:tms/responsive.dart';
import 'package:tms/views/match_control/match_control_handler.dart';
import 'package:tms/views/shared/dashboard/matches/matches.dart';
import 'package:tms/views/shared/dashboard/side_menu_tile.dart';

class MatchSideMenu extends StatelessWidget {
  final Function(Widget view) onView;
  const MatchSideMenu({Key? key, required this.onView}) : super(key: key);

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
            title: 'Match Control',
            svgSrc: 'assets/icons/shuffle.svg',
            press: () => _handleViewSwitch(const MatchControlHandler(), context),
          ),
          DrawerListTile(
            title: 'Match Edit',
            svgSrc: 'assets/icons/table.svg',
            press: () => _handleViewSwitch(const Matches(), context),
          ),
        ],
      ),
    );
  }
}
