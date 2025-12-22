import 'package:flutter/material.dart';
import 'package:tms_client/colors.dart';
import 'package:tms_client/router/app_routes.dart';
import 'package:tms_client/views/home/grid_card.dart';
import 'package:tms_client/views/home/grid_list.dart';

class AdminCards extends StatelessWidget {
  const AdminCards({super.key});

  @override
  Widget build(BuildContext context) {
    return GridList(
      cards: [
        GridCard(
          icon: Icons.handyman,
          title: 'Setup',
          subtitle: 'ADMIN',
          bannerColor: vibrantColors(2),
          onTap: () => AppRoute.setup.go(context),
        ),
        GridCard(
          icon: Icons.dashboard,
          title: 'Dashboard',
          subtitle: 'ADMIN',
          bannerColor: vibrantColors(3),
          onTap: () => AppRoute.dashboard.go(context),
        ),
      ],
    );
  }
}
