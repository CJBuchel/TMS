import 'package:echo_tree_flutter/logging/logger.dart';

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
    // EchoTreeLogger().d("Subscribing to: $topics");
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
    // EchoTreeLogger().d("Unsubscribing from: $topics");
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

  // Forces all topics to be unsubscribed
  void triggerAllUnsubscribe() {
    EchoTreeLogger().w("Triggering All Unsubscribes: $_topicList");
    for (var topic in _topicList.keys) {
      for (var callback in _unsubscribeCallbacks) {
        callback(topic);
      }
    }

    _topicList.clear();
  }

  // Forces all topics to be re-subscribed
  void triggerAllSubscribe() {
    EchoTreeLogger().w("Triggering All Subscriptions: $_topicList");
    for (var topic in _topicList.keys) {
      for (var callback in _subscribeCallbacks) {
        callback(topic);
      }
    }
  }
}
