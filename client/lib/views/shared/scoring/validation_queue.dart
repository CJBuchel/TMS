import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/senders/validation_sender.dart';
import 'package:tms/utils/copy.dart';

class ValidationQueue {
  ValidationQueue._internal();
  static final ValidationQueue _instance = ValidationQueue._internal();

  factory ValidationQueue() {
    return _instance;
  }

  final Queue<Function> _validationQueue = Queue();
  bool _isCurrentlyValidating = false;
  List<ScoreAnswer> _nextAnswers = [];

  // internal method to process queue
  Future<void> _processQueue() async {
    while (_validationQueue.isNotEmpty) {
      _isCurrentlyValidating = true;
      var currentTask = _validationQueue.removeFirst();
      await currentTask.call();
    }
    _isCurrentlyValidating = false;

    // recheck if tasks were added during the processing of the last
    if (_validationQueue.isNotEmpty && !_isCurrentlyValidating) {
      _processQueue();
    }
  }

  void _addValidation(Function validationTask) {
    _validationQueue.add(validationTask);
    if (!_isCurrentlyValidating) {
      _processQueue();
    }
  }

  void validate(List<ScoreAnswer> answers) {
    if (!listEquals(answers, _nextAnswers)) {
      // Logger().wtf("Not the same, requesting validation, size: ${answers.length}");
      _nextAnswers = deepCopyList(answers, ScoreAnswer.fromJson);
      _addValidation(() {
        senderValidation(_nextAnswers);
      });
    } else {
      Logger().e("list the same, not sending validation request");
    }
  }
}
