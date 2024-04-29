class EchoTreeSubscriptionManager {
  final Map<String, int> _topicList = {};
  final List<Function(String)> _subscribeCallbacks = [];
  final List<Function(String)> _unsubscribeCallbacks = [];

  // do something when the first subscription is made
  void onFirstSubscribe(Function(String) callback) {
    _subscribeCallbacks.add(callback);
  }

  // do something when the last subscription to this topic is removed
  void onLastUnsubscribe(Function(String) callback) {
    _unsubscribeCallbacks.add(callback);
  }

  void subscribe(List<String> topics) {
    for (var topic in topics) {
      if (_topicList.containsKey(topic)) {
        _topicList[topic] = _topicList[topic]! + 1;
      } else {
        _topicList[topic] = 1;
        for (var callback in _subscribeCallbacks) {
          callback(topic);
        }
      }
    }
  }

  void unsubscribe(List<String> topics) {
    for (var topic in topics) {
      if (_topicList.containsKey(topic)) {
        _topicList[topic] = _topicList[topic]! - 1;
        if (_topicList[topic] == 0) {
          _topicList.remove(topic);
          for (var callback in _unsubscribeCallbacks) {
            callback(topic);
          }
        }
      }
    }
  }

  void unsubscribeAll() {
    for (var topic in _topicList.keys) {
      for (var callback in _unsubscribeCallbacks) {
        callback(topic);
      }
    }

    _topicList.clear();
  }
}
