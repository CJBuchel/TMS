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

  void subscribe(List<String> trees) {
    // EchoTreeLogger().d("Subscribing to: $topics");
    for (var tree in trees) {
      if (_topicList.containsKey(tree)) {
        _topicList[tree] = _topicList[tree]! + 1;
      } else {
        _topicList[tree] = 1;
        for (var callback in _subscribeCallbacks) {
          callback(tree);
        }
      }
    }
  }

  void unsubscribe(List<String> trees) {
    // EchoTreeLogger().d("Unsubscribing from: $topics");
    for (var tree in trees) {
      if (_topicList.containsKey(tree)) {
        _topicList[tree] = _topicList[tree]! - 1;
        if (_topicList[tree] == 0) {
          _topicList.remove(tree);
          for (var callback in _unsubscribeCallbacks) {
            callback(tree);
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
