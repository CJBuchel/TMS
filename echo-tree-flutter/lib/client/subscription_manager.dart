import 'dart:async';

import 'package:echo_tree_flutter/logging/logger.dart';

// manager to monitor how many subscriptions are made to a topic
// when the first subscription is made, it will trigger a subscribe callback
// when the last subscription is removed, it will trigger an unsubscribe callback
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

  Future<void> subscribe(List<String> trees) async {
    await Future.forEach(trees, (tree) async {
      if (_topicList.containsKey(tree)) {
        _topicList[tree] = _topicList[tree]! + 1;
      } else {
        _topicList[tree] = 1;
        for (var callback in _subscribeCallbacks) {
          scheduleMicrotask(() => callback(tree));
        }
      }
    });
  }

  void unsubscribe(List<String> trees) async {
    await Future.forEach(trees, (tree) async {
      if (_topicList.containsKey(tree)) {
        _topicList[tree] = _topicList[tree]! - 1;
        if (_topicList[tree] == 0) {
          _topicList.remove(tree);
          for (var callback in _unsubscribeCallbacks) {
            scheduleMicrotask(() => callback(tree));
          }
        }
      }
    });
  }

  // Forces all topics to be unsubscribed
  Future<void> triggerAllUnsubscribe() async {
    EchoTreeLogger().w("Triggering All Unsubscribes: $_topicList");

    await Future.forEach(_topicList.keys, (topic) async {
      for (var callback in _unsubscribeCallbacks) {
        scheduleMicrotask(() => callback(topic));
      }
    });

    _topicList.clear();
  }

  // Forces all topics to be re-subscribed
  Future<void> triggerAllSubscribe() async {
    EchoTreeLogger().w("Triggering All Subscriptions: $_topicList");

    await Future.forEach(_topicList.keys, (topic) async {
      for (var callback in _subscribeCallbacks) {
        scheduleMicrotask(() => callback(topic));
      }
    });
  }
}
