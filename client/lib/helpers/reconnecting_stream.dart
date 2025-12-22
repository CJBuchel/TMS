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
  StreamController<bool>? _connectionStateController;
  StreamSubscription<T>? _subscription;
  Timer? _retryTimer;
  bool _closed = false;
  bool _isConnected = false;
  int _retryCount = 0;

  ReconnectingStream(
    Future<ResponseStream<T>> Function() createStream, {
    Duration retryDelay = const Duration(seconds: 1),
    Duration maxRetryDelay = const Duration(seconds: 16),
  }) : _createStream = createStream,
       _retryDelay = retryDelay,
       _maxRetryDelay = maxRetryDelay;

  Stream<T> get stream {
    _controller ??= StreamController<T>.broadcast(onListen: _connect);
    return _controller!.stream;
  }

  /// Stream that emits true when connected, false when disconnected
  Stream<bool> get connectionState async* {
    // Emit initial state immediately
    yield _isConnected;

    // Ensure controller exists and start connecting
    if (_connectionStateController == null) {
      _connectionStateController = StreamController<bool>.broadcast();

      // Start connecting when first listener attaches
      if (!_closed && _subscription == null && _retryTimer == null) {
        _connect();
      }
    }

    // Then yield all subsequent changes
    await for (final value in _connectionStateController!.stream) {
      yield value;
    }
  }

  /// Current connection status
  bool get isConnected => _isConnected;

  void _setConnectionState(bool connected) {
    if (_isConnected != connected) {
      _isConnected = connected;
      _connectionStateController?.add(connected);
    }
  }

  Future<void> _connect() async {
    if (_closed) return;

    try {
      final grpcStream = await _createStream();
      bool firstDataReceived = false;
      _subscription = grpcStream.listen(
        (data) {
          if (!_closed) {
            if (!firstDataReceived) {
              firstDataReceived = true;
              _setConnectionState(true); // Only set connected after first data
            }
            _retryCount = 0; // Reset on successful data
            _controller?.add(data);
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!_closed) {
            logger.w('Stream error: $error');
            _setConnectionState(false);
            _scheduleReconnect();
          }
        },
        onDone: () {
          if (!_closed) {
            logger.i('Stream ended, reconnecting...');
            _setConnectionState(false);
            _scheduleReconnect();
          }
        },
      );
    } catch (e) {
      if (!_closed) {
        logger.e('Failed to connect: $e');
        _setConnectionState(false);
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
    _setConnectionState(false);
    _retryTimer?.cancel();
    _subscription?.cancel();
    _controller?.close();
    _connectionStateController?.close();
  }
}
