import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/app.dart';
import 'package:tms_client/helpers/local_storage.dart';
import 'package:tms_client/utils/logger.dart';

void main() async {
  // Ensure flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  logger.i("Starting TMS Client...");

  // Init local storage
  await initializeLocalStorage();

  runApp(ProviderScope(child: TmsApp()));
}
