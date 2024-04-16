import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:tms/providers/auth_provider.dart';

class Login extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthProvider _authProvider = AuthProvider();

  void _loginController(BuildContext context) async {
    int status = await _authProvider.login(_usernameController.text, _passwordController.text);

    if (status == HttpStatus.ok) {
      context.canPop() ? context.pop() : GoRouter.of(context).go('/');
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Failed'),
          content: Text(status == HttpStatus.unauthorized ? "Incorrect Username or Password" : "Server Error: $status"),
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

        // Username
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 400,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                    hintText: 'Enter username, e.g `admin`',
                  ),
                ),
              ),
            ),
          ],
        ),

        // Password
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 400,
              child: Padding(
                padding: const EdgeInsets.only(left: 0, right: 0, bottom: 25),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter password, e.g `password1!`',
                  ),
                ),
              ),
            )
          ],
        ),

        // Login button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _loginController(context),
                icon: const Icon(Icons.login),
                label: const Text("Login"),
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
