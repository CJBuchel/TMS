// lib/utils/reconnecting_stream.dart
import 'dart:async';
import 'package:grpc/grpc.dart';
import 'package:tms_client/utils/logger.dart';

/// Wraps a gRPC stream with automatic reconnection on failures
class ReconnectingStream<T> {
  final Future<ResponseStream<T>> Function() _createStream;
  final Duration _retryDelay;
  final Duration _maxRetryDelay;

  StreamController<T>? _controller;
  StreamSubscription<T>? _subscription;
  Timer? _retryTimer;
  bool _closed = false;
  int _retryCount = 0;

  ReconnectingStream(
    Future<ResponseStream<T>> Function() createStream, {
    Duration retryDelay = const Duration(seconds: 1),
    Duration maxRetryDelay = const Duration(seconds: 16),
  }) : _createStream = createStream,
       _retryDelay = retryDelay,
       _maxRetryDelay = maxRetryDelay;

  Stream<T> get stream {
    _controller ??= StreamController<T>.broadcast(
      onListen: _connect,
      onCancel: close,
    );
    return _controller!.stream;
  }

  Future<void> _connect() async {
    if (_closed) return;

    try {
      final grpcStream = await _createStream();
      _subscription = grpcStream.listen(
        (data) {
          if (!_closed) {
            _retryCount = 0; // Reset on successful data
            _controller?.add(data);
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!_closed) {
            logger.w('Stream error: $error');
            _scheduleReconnect();
          }
        },
        onDone: () {
          if (!_closed) {
            logger.i('Stream ended, reconnecting...');
            _scheduleReconnect();
          }
        },
      );
    } catch (e) {
      if (!_closed) {
        logger.e('Failed to connect: $e');
        _scheduleReconnect();
      }
    }
  }

  void _scheduleReconnect() {
    _subscription?.cancel();
    _retryTimer?.cancel();

    // Exponential backoff: 1s, 2s, 4s, 8s... up to maxRetryDelay
    final delayMs = (_retryDelay.inMilliseconds * (1 << _retryCount)).clamp(
      _retryDelay.inMilliseconds,
      _maxRetryDelay.inMilliseconds,
    );

    _retryCount++;
    logger.d('Reconnecting in ${delayMs}ms...');

    _retryTimer = Timer(Duration(milliseconds: delayMs), _connect);
  }

  void close() {
    _closed = true;
    _retryTimer?.cancel();
    _subscription?.cancel();
    _controller?.close();
  }
}
