enum BaseCheckMessageType {
  error,
  warning,
}

class BaseCheckMessage {
  final String message;
  final BaseCheckMessageType type;
  final String? teamNumber;
  final String? matchNumber;
  final String? sessionNumber;

  BaseCheckMessage({
    required this.message,
    required this.type,
    this.teamNumber,
    this.matchNumber,
    this.sessionNumber,
  });

  String get _matchCheckMessage {
    if (teamNumber != null && matchNumber != null) {
      return 'Team: $teamNumber, Match: $matchNumber, $message';
    } else if (matchNumber != null) {
      return 'Match: $matchNumber, $message';
    } else {
      return message;
    }
  }

  String get _sessionCheckMessage {
    if (teamNumber != null && sessionNumber != null) {
      return 'Team: $teamNumber, Session: $sessionNumber, $message';
    } else if (sessionNumber != null) {
      return 'Session: $sessionNumber, $message';
    } else {
      return message;
    }
  }

  String get formattedMessage {
    if (teamNumber != null && matchNumber != null && sessionNumber != null) {
      return 'Team: $teamNumber, Match: $matchNumber, Session: $sessionNumber, $message';
    } else if (teamNumber != null || matchNumber != null) {
      return _matchCheckMessage;
    } else if (teamNumber != null || sessionNumber != null) {
      return _sessionCheckMessage;
    } else if (teamNumber != null) {
      return 'Team: $teamNumber, $message';
    } else {
      return message;
    }
  }
}
