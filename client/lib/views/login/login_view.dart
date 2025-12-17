import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/providers/auth_provider.dart';
import 'package:tms_client/utils/logger.dart';

class LoginView extends ConsumerWidget {
  LoginView({super.key});

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _loginController(BuildContext context, WidgetRef ref) async {
    final nt = ref.read(userServiceProvider.notifier);
    try {
      await nt.login(_usernameController.text, _passwordController.text);
    } catch (e) {
      logger.e('Login Error: $e');
    }

    // if (status == HttpStatus.ok) {
    //   context.canPop() ? context.pop() : GoRouter.of(context).go('/');
    // } else {
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text('Login failed')));
    // }
  }

  Widget _logo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 25),
          child: Image.asset('assets/logos/TMS_Logo.png', width: 200),
        ),
      ],
    );
  }

  Widget _username() {
    return SizedBox(
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
    );
  }

  Widget _password() {
    return SizedBox(
      width: 400,
      child: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0, bottom: 25),
        child: TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Password',
            hintText: 'Enter password, e.g `admin`',
          ),
        ),
      ),
    );
  }

  Widget _loginButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => _loginController(context, ref),
        icon: const Icon(Icons.login),
        label: const Text('Login'),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              _logo(),
              _username(),
              _password(),
              _loginButton(context, ref),
            ],
          ),
        ),
      ),
    );
  }
}
