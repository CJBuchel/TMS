import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/auth_provider.dart';

class TmsAppBarLoginAction extends StatelessWidget {
  final GoRouterState state;

  const TmsAppBarLoginAction({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<AuthProvider, bool>(
      selector: (_, authProvider) => authProvider.isLoggedIn,
      builder: (_, isLoggedIn, __) => IconButton(
        onPressed: () {
          if (isLoggedIn) {
            if (state.matchedLocation == '/logout') {
              context.go('/');
            } else {
              context.goNamed('logout');
            }
          } else {
            if (state.matchedLocation == '/login') {
              context.go('/');
            } else {
              context.goNamed('login');
            }
          }
        },
        icon: Icon(
          isLoggedIn ? Icons.person : Icons.login,
          color: isLoggedIn ? Colors.white : Colors.red,
        ),
      ),
    );
  }
}
