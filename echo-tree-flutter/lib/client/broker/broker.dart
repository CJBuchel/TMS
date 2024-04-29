import 'package:echo_tree_flutter/client/broker/echo_item_broker.dart';
import 'package:echo_tree_flutter/client/broker/echo_tree_broker.dart';
import 'package:echo_tree_flutter/client/broker/responder_broker.dart';
import 'package:echo_tree_flutter/schemas/echo_tree_schema.dart';
import 'package:echo_tree_flutter/logging/logger.dart';

class EchoTreeMessageBroker {
  static final EchoTreeMessageBroker _instance = EchoTreeMessageBroker._internal();

  factory EchoTreeMessageBroker() {
    return _instance;
  }

  EchoTreeMessageBroker._internal();
  // broker method
  void broker(EchoTreeServerSocketMessage message) {
    // broker the message
    switch (message.messageEvent) {
      case EchoTreeServerSocketEvent.STATUS_RESPONSE_EVENT:
        EchoResponderBroker().broker(message.message ?? "");
        break;
      case EchoTreeServerSocketEvent.ECHO_ITEM_EVENT:
        EchoItemBroker().broker(message.message ?? "");
        break;
      case EchoTreeServerSocketEvent.ECHO_TREE_EVENT:
        EchoTreeBroker().broker(message.message ?? "");
        break;
      default:
        EchoTreeLogger().e("Unhandled event ${message.messageEvent}");
    }
  }
}
