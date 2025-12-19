import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/base/app_bar/login_action.dart';
import 'package:tms_client/base/app_bar/settings_action.dart';
import 'package:tms_client/base/app_bar/theme_action.dart';
import 'package:tms_client/colors.dart';
import 'package:tms_client/providers/health_provider.dart';
import 'package:tms_client/providers/tournament_provider.dart';

class BaseAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final GoRouterState state;
  final bool showActions;

  const BaseAppBar({super.key, required this.state, this.showActions = true});

  List<Widget> _actions() {
    if (!showActions) return [];
    return [
      BaseAppBarThemeAction(),
      SettingsAction(),
      BaseAppBarLoginAction(state: state),
    ];
  }

  Widget _title(bool isConnected, WidgetRef ref) {
    final tournamentStream = ref.watch(tournamentStreamProvider);

    if (isConnected) {
      return tournamentStream.when(
        data: (data) {
          return Text(
            data.tournament.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          );
        },
        loading: () => const Text('N/A'),
        error: (error, stack) =>
            Text('Error: $error', style: TextStyle(color: supportErrorColor)),
      );
    } else {
      return Text(
        'Disconnected',
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    }
  }

  Widget _leading(BuildContext context) {
    // Show home button only when not on home page
    final isHomePage = state.matchedLocation == '/';

    if (isHomePage) {
      return SizedBox.shrink(); // Hide button on home page
    }

    return IconButton(
      icon: Icon(Icons.home),
      onPressed: () => context.goNamed('home'),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(isConnectedProvider).value ?? false;

    return AppBar(
      backgroundColor: isConnected ? null : supportErrorColor,
      leading: _leading(context),
      title: _title(isConnected, ref),
      actions: _actions(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
