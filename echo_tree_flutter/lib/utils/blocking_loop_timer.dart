import 'dart:async';

class BlockingLoopTimer {
  final Duration interval;
  final Future<void> Function() callback;
  Timer? _timer;

  BlockingLoopTimer({required this.interval, required this.callback});

  void start() {
    _timer?.cancel();
    _timer = Timer(interval, _runCallback);
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void reset() {
    start();
  }

  void _runCallback() async {
    await callback();
    if (_timer != null) {
      start();
    }
  }
}
