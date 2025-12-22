import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tms_client/providers/auth_provider.dart';
import 'package:tms_client/utils/logger.dart';

part 'token_validator_provider.g.dart';

/// Provider that monitors app lifecycle and validates token when app resumes
@Riverpod(keepAlive: true)
class TokenValidator extends _$TokenValidator with WidgetsBindingObserver {
  @override
  void build() {
    // Register lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Cleanup when provider is disposed
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
    });

    // Validate token on initial app start
    _validateIfLoggedIn();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Validate token when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _validateIfLoggedIn();
    }
  }

  Future<void> _validateIfLoggedIn() async {
    final isLoggedIn = ref.read(isLoggedInProvider);

    // Only validate if user is logged in
    if (!isLoggedIn) {
      logger.d('Skipping token validation...');
      return;
    }

    logger.d('Validating token...');

    final userService = ref.read(userServiceProvider.notifier);
    final isValid = await userService.validateToken();

    if (!isValid) {
      logger.w('Token is invalid, logging out user');
      userService.logout();
    } else {
      logger.d('Token is valid');
    }
  }
}
