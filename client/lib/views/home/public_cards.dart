import 'package:flutter/material.dart';
import 'package:tms_client/colors.dart';
import 'package:tms_client/views/home/grid_card.dart';
import 'package:tms_client/views/home/grid_list.dart';

class PublicCards extends StatelessWidget {
  const PublicCards({super.key});

  @override
  Widget build(BuildContext context) {
    return GridList(
      cards: [
        GridCard(
          icon: Icons.scoreboard,
          title: 'Scoreboard',
          subtitle: 'PUBLIC',
          bannerColor: vibrantColors(0),
          onTap: () {},
        ),
        GridCard(
          icon: Icons.timer,
          title: 'Timer',
          subtitle: 'PUBLIC',
          bannerColor: vibrantColors(1),
          onTap: () {},
        ),
      ],
    );
  }
}
