import 'dart:io';

import 'package:tms/network/network.dart';
import 'package:tms/schema/tms_schema.dart';

Future<int> publishRequest(SocketMessage message) async {
  try {
    var res = await Network.serverPost("publish/", message.toJson());
    if (res.item1) {
      return Future.value(res.item2);
    } else {
      return Future.value(res.item2);
    }
  } catch (e) {
    return HttpStatus.badRequest;
  }
}
