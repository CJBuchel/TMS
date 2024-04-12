import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/auth_provider.dart';

class TmsAppBarLoginAction extends StatelessWidget {
  const TmsAppBarLoginAction({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AuthProvider, bool>(
      selector: (_, authProvider) => authProvider.isLoggedIn,
      builder: (_, isLoggedIn, __) => IconButton(
        onPressed: () {
          if (!isLoggedIn) {
            context.pushNamed('login');
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
