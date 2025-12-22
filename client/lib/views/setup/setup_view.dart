import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/providers/tournament_provider.dart';
import 'package:tms_client/views/setup/database_setup_tab.dart';
import 'package:tms_client/views/setup/game_setup_tab.dart';
import 'package:tms_client/views/setup/tournament_setup_tab.dart';

class SetupView extends HookConsumerWidget {
  const SetupView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 3);
    final tournament = ref.watch(tournamentStreamProvider);

    return Column(
      children: [
        TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Tournament Setup'),
            Tab(text: 'Game Setup'),
            Tab(text: 'Database Setup'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              TournamentSetupTab(tournament: tournament),
              GameSetupTab(tournament: tournament),
              DatabaseSetupTab(tournament: tournament),
            ],
          ),
        ),
      ],
    );
  }
}
