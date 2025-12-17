import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/base/app_bar/login_action.dart';
import 'package:tms_client/base/app_bar/theme_action.dart';
import 'package:tms_client/colors.dart';
import 'package:tms_client/providers/tournament_provider.dart';

class BaseAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final GoRouterState state;
  final bool showActions;

  const BaseAppBar({super.key, required this.state, this.showActions = true});

  List<Widget> _actions() {
    if (!showActions) return [];
    return [BaseAppBarThemeAction(), BaseAppBarLoginAction(state: state)];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentStream = ref.watch(tournamentStreamProvider);
    return AppBar(
      automaticallyImplyLeading: true,
      title: tournamentStream.when(
        data: (t) => Text(t.tournament.name),
        loading: () => const Text('N/A'),
        error: (error, stack) =>
            Text('Error: $error', style: TextStyle(color: supportErrorColor)),
      ),
      actions: _actions(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
