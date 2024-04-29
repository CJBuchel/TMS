import 'dart:convert';

import 'package:echo_tree_flutter/client/network_service.dart';
import 'package:echo_tree_flutter/logging/logger.dart';
import 'package:echo_tree_flutter/schemas/echo_tree_schema.dart';

class EchoTreeClient extends EchoTreeNetworkService {
  static final EchoTreeClient _instance = EchoTreeClient._internal();
  bool _initialized = false;
  bool get initialized => _initialized;

  factory EchoTreeClient() {
    return _instance;
  }

  EchoTreeClient._internal();

  @override
  Future<void> init(String dbPath, String metadataPath) async {
    await super.init(dbPath, metadataPath);
    _initialized = true;
  }

  @override
  Future<bool> connect(String address, {Map<String, String>? roles, List<String>? echoTrees}) async {
    if (initialized) {
      return await super.connect(address, roles: roles, echoTrees: echoTrees);
    } else {
      EchoTreeLogger().e("EchoTreeClient must be initialized before connection");
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
    if (initialized) {
      return await super.disconnect();
    } else {
      EchoTreeLogger().e("EchoTreeClient must be initialized before disconnection");
      return;
    }
  }

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
