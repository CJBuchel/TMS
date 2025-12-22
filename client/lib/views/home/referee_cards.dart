import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/colors.dart';
import 'package:tms_client/generated/common/common.pbenum.dart';
import 'package:tms_client/router/app_routes.dart';
import 'package:tms_client/views/home/grid_card.dart';
import 'package:tms_client/views/home/grid_list.dart';

class RefereeCards extends ConsumerWidget {
  final List<Role> roles;
  const RefereeCards({super.key, required this.roles});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridList(
      cards: [
        GridCard(
          icon: Icons.sports_score,
          title: 'Referee',
          subtitle: 'REFEREE',
          bannerColor: vibrantColors(4),
          onTap: () => AppRoute.referee.go(context),
        ),
        GridCard(
          icon: Icons.shuffle,
          title: 'Match Controller',
          subtitle: 'REFEREE',
          bannerColor: vibrantColors(5),
          onTap: () => AppRoute.matchController.go(context),
        ),
      ],
    );
  }
}
