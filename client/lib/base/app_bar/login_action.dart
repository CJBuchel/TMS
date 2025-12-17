import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/providers/auth_provider.dart';

class BaseAppBarLoginAction extends ConsumerWidget {
  final GoRouterState state;
  const BaseAppBarLoginAction({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);

    return IconButton(
      icon: Icon(isLoggedIn ? Icons.logout : Icons.login),
      onPressed: () {
        if (isLoggedIn) {
          // If we're logged in, and our current location is 'logout'. Go home
          if (state.matchedLocation == '/logout') {
            context.goNamed('home');
          } else {
            context.goNamed('logout');
          }
        } else {
          // if we're not logged in, and our current location is 'login', go home
          if (state.matchedLocation == '/login') {
            context.goNamed('home');
          } else {
            context.goNamed('login');
          }
        }
      },
    );
  }
}
