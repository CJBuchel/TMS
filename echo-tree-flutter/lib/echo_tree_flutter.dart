import 'dart:convert';

import 'package:echo_tree_flutter/client/network_service.dart';
import 'package:echo_tree_flutter/schemas/echoTreeSchema.dart';

class EchoTreeClient extends EchoTreeNetworkService {
  static final EchoTreeClient _instance = EchoTreeClient._internal();

  factory EchoTreeClient() {
    return _instance;
  }

  EchoTreeClient._internal();

  void insert(String treeName, String key, String json) async {
    if (state != EchoTreeConnection.connected) {
      return;
    }

    // create the event
    var event = InsertEvent(
      treeName: treeName,
      key: key,
      data: json,
    ).toJson();

    // create the message
    EchoTreeClientSocketMessage message = EchoTreeClientSocketMessage(
      authToken: authToken,
      messageEvent: EchoTreeClientSocketEvent.INSERT_EVENT,
      message: jsonEncode(event),
    );

    // send the event
    sendMessage(message);
  }

  void get(String treeName, String key) {
    if (state != EchoTreeConnection.connected) {
      return;
    }

    // create the message
    var event = GetEvent(
      treeName: treeName,
      key: key,
    ).toJson();

    // create the message
    EchoTreeClientSocketMessage message = EchoTreeClientSocketMessage(
      authToken: authToken,
      messageEvent: EchoTreeClientSocketEvent.GET_EVENT,
      message: jsonEncode(event),
    );

    // send the event
    sendMessage(message);
  }

  void delete(Map<String, String> treeItems) {
    if (state != EchoTreeConnection.connected) {
      return;
    }

    // create the message
    var event = DeleteEvent(
      treeItems: treeItems,
    ).toJson();

    // create the message
    EchoTreeClientSocketMessage message = EchoTreeClientSocketMessage(
      authToken: authToken,
      messageEvent: EchoTreeClientSocketEvent.DELETE_EVENT,
      message: jsonEncode(event),
    );

    // send the event
    sendMessage(message);
  }

  void setTree(Map<String, Map<String, String>> trees) {
    if (state != EchoTreeConnection.connected) {
      return;
    }

    // create the message
    var event = SetTreeEvent(
      trees: trees,
    ).toJson();

    // create the message
    EchoTreeClientSocketMessage message = EchoTreeClientSocketMessage(
      authToken: authToken,
      messageEvent: EchoTreeClientSocketEvent.SET_TREE_EVENT,
      message: jsonEncode(event),
    );

    // send the event
    sendMessage(message);
  }

  void getTree(List<String> treeNames) {
    if (state != EchoTreeConnection.connected) {
      return;
    }

    // create the message
    var event = GetTreeEvent(
      treeNames: treeNames,
    ).toJson();

    // create the message
    EchoTreeClientSocketMessage message = EchoTreeClientSocketMessage(
      authToken: authToken,
      messageEvent: EchoTreeClientSocketEvent.GET_TREE_EVENT,
      message: jsonEncode(event),
    );

    // send the event
    sendMessage(message);
  }
}
