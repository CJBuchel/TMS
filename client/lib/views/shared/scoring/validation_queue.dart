import 'dart:collection';

class ValidationQueue {
  static final ValidationQueue _instance = ValidationQueue._internal();

  factory ValidationQueue() {
    return _instance;
  }

  ValidationQueue._internal();

  final Queue<Function> _validationQueue = Queue();
  bool _isCurrentlyValidating = false;

  // internal method to process queue
  Future<void> _processQueue() async {
    while (_validationQueue.isNotEmpty) {
      _isCurrentlyValidating = true;
      var currentTask = _validationQueue.removeFirst();
      await currentTask.call();
    }
    _isCurrentlyValidating = false;
  }

  void addValidation(Function validationTask) {
    _validationQueue.add(validationTask);
    if (!_isCurrentlyValidating) {
      _processQueue();
    }
  }
}
