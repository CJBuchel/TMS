import 'package:tms/generated/infra/network_schemas/socket_protocol/match_time_event.dart';
import 'package:tms/generated/infra/network_schemas/socket_protocol/server_socket_protocol.dart';
import 'package:tms/mixins/server_event_subscriber_mixin.dart';
import 'package:tms/providers/tournament_config_provider.dart';
import 'package:tms/services/game_timer_service.dart';
import 'package:tms/utils/logger.dart';

enum TimerRunState {
  idle,
  countdown,
  running,
  endgame,
  ended,
  stopped,
}

class GameTimerProvider extends TournamentConfigProvider with ServerEventSubscribeNotifierMixin {
  GameTimerService _gameTimerService = GameTimerService();
  TimerRunState _timerState = TimerRunState.idle;
  int _timer = 150; // in seconds (default)

  // list of callbacks
  List<Function(TimerRunState state)> _callbacks = [];

  void addTimerStateChangeListener(Function(TimerRunState state) callback) {
    TmsLogger().i("Adding callback to GameTimerProvider");
    _callbacks.add(callback);
  }

  void removeTimerStateChangeListener(Function(TimerRunState state) callback) {
    _callbacks.remove(callback);
    TmsLogger().w("Removing callback from GameTimerProvider callbacks: ${_callbacks.length}");
  }

  void _triggerCallbacks(TimerRunState state) {
    _callbacks.forEach((callback) {
      callback(state);
    });
  }

  void _setTimer(int? time) {
    _timer = time ?? _timer;
  }

  @override
  void dispose() {
    _callbacks.clear();
    TmsLogger().w("GameTimerProvider disposed, callbacks clear");
    super.dispose();
  }

  GameTimerProvider() {
    _timerState = TimerRunState.idle;
    _timer = super.timerLength;

    subscribeToEvent(TmsServerSocketEvent.matchTimerEvent, (event) {
      if (event.message != null) {
        // handle timer event
        try {
          TmsServerMatchTimerEvent timerEvent = TmsServerMatchTimerEvent.fromJsonString(json: event.message!);
          switch (timerEvent.state) {
            case TmsServerMatchTimerState.startWithCountdown:
              _setTimer(timerEvent.time);
              _timerState = TimerRunState.countdown;
              _triggerCallbacks(_timerState);
              break;
            case TmsServerMatchTimerState.start:
              _setTimer(timerEvent.time);
              _timerState = TimerRunState.running;
              _triggerCallbacks(_timerState);
              break;
            case TmsServerMatchTimerState.stop:
              _timerState = TimerRunState.stopped;
              _triggerCallbacks(_timerState);
              break;
            case TmsServerMatchTimerState.end:
              _timerState = TimerRunState.ended;
              _triggerCallbacks(_timerState);
              break;
            case TmsServerMatchTimerState.time:
              if (_timerState == TimerRunState.idle) {
                _timerState = TimerRunState.running;
              }
              _setTimer(timerEvent.time);
              break;
            case TmsServerMatchTimerState.endgame:
              _setTimer(timerEvent.time);
              _timerState = TimerRunState.endgame;
              _triggerCallbacks(_timerState);
              break;
            case TmsServerMatchTimerState.reload:
              _setTimer(timerLength);
              _timerState = TimerRunState.idle;
              _triggerCallbacks(_timerState);
              break;
            default:
              TmsLogger().w("Unknown timer event state: ${timerEvent.state}");
              break;
          }
          notifyListeners();
        } catch (e) {
          TmsLogger().e("Error parsing timer event: $e");
        }
      }
    });
  }

  int get timer => _timerState == TimerRunState.idle ? timerLength : _timer;
  TimerRunState get timerState => _timerState;

  Future<int> startTimer() async {
    return _gameTimerService.startTimer();
  }

  Future<int> startTimerWithCountdown() async {
    return _gameTimerService.startTimerWithCountdown();
  }

  Future<int> stopTimer() async {
    return _gameTimerService.stopTimer();
  }

  bool get canStart => _timerState == TimerRunState.idle;
  bool get canStop {
    return _timerState != TimerRunState.idle &&
        _timerState != TimerRunState.ended &&
        _timerState != TimerRunState.stopped;
  }

  bool get canReload => _timerState == TimerRunState.ended || _timerState == TimerRunState.stopped;
}
