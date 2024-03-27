class OperationTimeoutTracker {
  final Duration timeout;
  final DateTime startTime;

  OperationTimeoutTracker(this.timeout) : startTime = DateTime.now();

  bool get isTimedOut => DateTime.now().difference(startTime) > timeout;
}
