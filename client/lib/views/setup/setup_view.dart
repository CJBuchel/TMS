import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/views/setup/tournament_setup_tab.dart';

class SetupView extends HookConsumerWidget {
  const SetupView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 3);

    return Column(
      children: [
        TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Tournament Setup'),
            Tab(text: 'Game Setup'),
            Tab(text: 'User Setup'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: const [
              TournamentSetupTab(),
              _GameSetupTab(),
              _UserSetupTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class _GameSetupTab extends StatelessWidget {
  const _GameSetupTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Game Setup Content'));
  }
}

class _UserSetupTab extends StatelessWidget {
  const _UserSetupTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('User Setup Content'));
  }
}
