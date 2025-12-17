import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/providers/auth_provider.dart';
import 'package:tms_client/utils/grpc_result.dart';
import 'package:tms_client/widgets/dialogs/popup_dialog.dart';

class LoginView extends HookConsumerWidget {
  const LoginView({super.key});

  Widget _logo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 25),
          child: Image.asset('assets/logos/TMS_Logo.png', width: 150),
        ),
      ],
    );
  }

  Widget _username(TextEditingController controller) {
    return SizedBox(
      width: 400,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Username',
            hintText: 'Enter username, e.g `admin`',
          ),
        ),
      ),
    );
  }

  Widget _password(TextEditingController controller) {
    return SizedBox(
      width: 400,
      child: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0, bottom: 25),
        child: TextField(
          controller: controller,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isLoading = useState(false);
    final isLoggedIn = ref.watch(isLoggedInProvider);
    final username = ref.watch(usernameProvider);

    void handleLogin() async {
      isLoading.value = true;
      final result = await ref
          .read(userServiceProvider.notifier)
          .login(usernameController.text, passwordController.text);

      if (context.mounted && result is GrpcFailure) {
        PopupDialog.fromGrpcStatus(result: result).show(context);
      }
      isLoading.value = false;
    }

    Widget loginWidget() {
      return Column(
        children: [
          _logo(),
          _username(usernameController),
          _password(passwordController),
          if (isLoading.value)
            const CircularProgressIndicator()
          else
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: handleLogin,
                icon: const Icon(Icons.login),
                label: const Text('Login'),
              ),
            ),
        ],
      );
    }

    Widget logoutWidget() {
      return Column(
        children: [
          _logo(),
          Text('Logged in as $username'),
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => ref.read(userServiceProvider.notifier).logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ),
        ],
      );
    }

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: isLoggedIn ? logoutWidget() : loginWidget(),
        ),
      ),
    );
  }
}
