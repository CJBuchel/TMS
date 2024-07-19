import 'package:tms/generated/infra/network_schemas/socket_protocol/match_time_event.dart';
import 'package:tms/generated/infra/network_schemas/socket_protocol/server_socket_protocol.dart';
import 'package:tms/mixins/server_event_subscriber_mixin.dart';
import 'package:tms/providers/event_config_provider.dart';
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

class GameTimerProvider extends EventConfigProvider with ServerEventSubscribeNotifierMixin {
  GameTimerService _gameTimerService = GameTimerService();
  TimerRunState _timerState = TimerRunState.idle;
  int _timer = 150; // in seconds

  void _setTimer(int? time) {
    _timer = time ?? _timer;
  }

  GameTimerProvider() {
    _timer = timerLength;
    _timerState = TimerRunState.idle;

    subscribeToEvent(TmsServerSocketEvent.matchTimerEvent, (event) {
      if (event.message != null) {
        // handle timer event
        try {
          TmsServerMatchTimerEvent timerEvent = TmsServerMatchTimerEvent.fromJsonString(json: event.message!);
          switch (timerEvent.state) {
            case TmsServerMatchTimerState.startWithCountdown:
              TmsLogger().i("Timer started with countdown: ${timerEvent.time}");
              _setTimer(timerEvent.time);
              _timerState = TimerRunState.countdown;
              break;
            case TmsServerMatchTimerState.start:
              TmsLogger().i("Timer started: ${timerEvent.time}");
              _setTimer(timerEvent.time);
              _timerState = TimerRunState.running;
              break;
            case TmsServerMatchTimerState.stop:
              TmsLogger().i("Timer stopped: ${timerEvent.time}");
              _timerState = TimerRunState.stopped;
              break;
            case TmsServerMatchTimerState.end:
              TmsLogger().i("Timer ended: ${timerEvent.time}");
              _timerState = TimerRunState.ended;
              break;
            case TmsServerMatchTimerState.time:
              TmsLogger().t("Timer time: ${timerEvent.time}");
              _setTimer(timerEvent.time);
              break;
            case TmsServerMatchTimerState.endgame:
              TmsLogger().i("Timer endgame: ${timerEvent.time}");
              _setTimer(timerEvent.time);
              _timerState = TimerRunState.endgame;
              break;
            case TmsServerMatchTimerState.reload:
              TmsLogger().i("Timer reload: ${timerEvent.time}");
              _setTimer(timerLength);
              _timerState = TimerRunState.idle;
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

  int get timer => _timer;
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
}
