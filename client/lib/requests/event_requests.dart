import 'dart:io';

import 'package:logger/logger.dart';
import 'package:tms/network/auth.dart';
import 'package:tms/network/network.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tuple/tuple.dart';

Future<int> setupEventRequest(SetupRequest request) async {
  try {
    request.authToken = await NetworkAuth().getToken();
    var res = await Network().serverPost("event/setup", request.toJson());

    if (res.item1) {
      return res.item2;
    } else {
      return res.item2;
    }
  } catch (e) {
    Logger().e(e);
    return HttpStatus.badRequest;
  }
}

Future<int> setEventRequest(Event event) async {
  try {
    var message = UpdateEventRequest(authToken: await NetworkAuth().getToken(), event: event);
    var res = await Network().serverPost("event/set", message.toJson());

    if (res.item1) {
      return res.item2;
    } else {
      return res.item2;
    }
  } catch (e) {
    Logger().e(e);
    return HttpStatus.badRequest;
  }
}

Future<Tuple2<int, Event?>> getEventRequest() async {
  try {
    var res = await Network().serverGet("event/get");

    if (res.item1 && res.item3.isNotEmpty) {
      return Tuple2(res.item2, EventResponse.fromJson(res.item3).event);
    } else {
      return Tuple2(res.item2, null);
    }
  } catch (e) {
    Logger().e(e);
    return const Tuple2(HttpStatus.badRequest, null);
  }
}

Future<int> purgeEventRequest() async {
  try {
    var message = PurgeRequest(authToken: await NetworkAuth().getToken());
    var res = await Network().serverPost("event/purge", message.toJson());

    if (res.item1) {
      return res.item2;
    } else {
      return res.item2;
    }
  } catch (e) {
    Logger().e(e);
    return HttpStatus.badRequest;
  }
}
