import 'dart:io';

import 'package:logger/logger.dart';
import 'package:tms/network/auth.dart';
import 'package:tms/network/network.dart';
import 'package:tms/schema/tms_schema.dart';

Future<int> timerStartRequest() async {
  try {
    var message = TimerRequest(authToken: await NetworkAuth().getToken());
    var res = await Network().serverPost("timer/start", message.toJson());

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

Future<int> timerPreStartRequest() async {
  try {
    var message = TimerRequest(authToken: await NetworkAuth().getToken());
    var res = await Network().serverPost("timer/pre_start", message.toJson());

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

Future<int> timerStopRequest() async {
  try {
    var message = TimerRequest(authToken: await NetworkAuth().getToken());
    var res = await Network().serverPost("timer/stop", message.toJson());

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

Future<int> timerReloadRequest() async {
  try {
    var message = TimerRequest(authToken: await NetworkAuth().getToken());
    var res = await Network().serverPost("timer/reload", message.toJson());

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
