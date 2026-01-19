import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shared_ticker_provider.g.dart';

/// Shared ticker that emits the current DateTime at a configurable interval.
/// Multiple widgets using the same interval will share the same ticker.
@Riverpod(keepAlive: true)
Stream<DateTime> sharedTicker(Ref ref, Duration interval) {
  late final StreamController<DateTime> controller;
  late final Timer timer;

  controller = StreamController<DateTime>(
    onListen: () {
      // Emit immediately on first listen
      controller.add(DateTime.now());
      timer = Timer.periodic(interval, (_) {
        controller.add(DateTime.now());
      });
    },
    onCancel: () {
      timer.cancel();
      controller.close();
    },
  );

  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  return controller.stream;
}
