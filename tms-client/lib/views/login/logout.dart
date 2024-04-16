import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:tms/providers/auth_provider.dart';

class Logout extends StatelessWidget {
  final AuthProvider _authProvider = AuthProvider();

  void _logoutController(BuildContext context) async {
    int status = await _authProvider.logout();
    if (status == HttpStatus.ok) {
      context.canPop() ? context.pop() : GoRouter.of(context).go('/');
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Logout Failed'),
          content: Text('Server Error: $status'),
          actions: <Widget>[
            TextButton(
              onPressed: () => context.canPop() ? context.pop() : GoRouter.of(context).go('/'),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildWidgets(BuildContext context) {
    String username = _authProvider.username;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 25),
              child: Image.asset(
                'assets/logos/TMS_LOGO_NO_TEXT.png',
                width: 200,
              ),
            ),
          ],
        ),

        // currently logged in
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 25),
              child: Text(
                'Logged in as: $username',
                // style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),

        // logout button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton.icon(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                  overlayColor: MaterialStateProperty.all<Color>(Colors.orange[800] ?? Colors.orange),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: const BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                onPressed: () => _logoutController(context),
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _scrolledInner(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: _buildWidgets(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MaxWidthBox(
        maxWidth: 1000,
        child: ResponsiveScaledBox(
          width: ResponsiveValue<double>(
            context,
            defaultValue: 800,
            conditionalValues: const [
              Condition.equals(name: MOBILE, value: 500),
              Condition.between(start: 601, end: 800, value: 900),
              Condition.largerThan(name: TABLET, value: 1100),
            ],
          ).value,
          child: _scrolledInner(context),
        ),
      ),
    );
  }
}
