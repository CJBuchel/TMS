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
      icon: Icon(isLoggedIn ? Icons.person : Icons.login),
      onPressed: () {
        context.pushNamed('login');
      },
    );
  }
}
