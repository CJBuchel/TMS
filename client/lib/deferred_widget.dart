import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DeferredWidget extends HookConsumerWidget {
  final String libraryKey;
  final Future<void> Function() libraryLoader;
  final WidgetBuilder builder;
  final Widget? placeholder;
  final Duration minimumLoadDuration;

  static final Set<String> _loadedLibraries = {};

  const DeferredWidget({
    super.key,
    required this.libraryKey,
    required this.libraryLoader,
    required this.builder,
    this.placeholder,
    this.minimumLoadDuration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryFuture = useMemoized(() async {
      if (!_loadedLibraries.contains(libraryKey)) {
        // First load: wait for both library AND minimum duration
        await Future.wait([
          libraryLoader(),
          Future<void>.delayed(minimumLoadDuration),
        ]);
        _loadedLibraries.add(libraryKey);
      } else {
        // Already loaded: instant
        await libraryLoader();
      }
    });

    final snapshot = useFuture(libraryFuture);

    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasError) {
        return Center(child: Text('Failed to load: ${snapshot.error}'));
      }
      return builder(context);
    }

    return placeholder ?? const Center(child: CircularProgressIndicator());
  }
}
