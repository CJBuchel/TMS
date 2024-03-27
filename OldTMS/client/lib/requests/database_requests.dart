import 'dart:io';

import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:tms/network/auth.dart';
import 'package:tms/network/network.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tuple/tuple.dart';

Future<Tuple2<int, List<Backup>>> getBackupsRequest() async {
  try {
    var message = BackupsRequest(authToken: await NetworkAuth().getToken()).toJson();
    var res = await Network().serverPost("backups/get", message);

    if (res.item1 && res.item3.isNotEmpty) {
      var backups = BackupsResponse.fromJson(res.item3).backups;
      return Tuple2(res.item2, backups);
    } else {
      return Tuple2(res.item2, []);
    }
  } catch (e) {
    Logger().e(e);
    return const Tuple2(HttpStatus.badRequest, []);
  }
}

Future<int> createBackupRequest() async {
  try {
    var message = BackupsRequest(authToken: await NetworkAuth().getToken()).toJson();
    var res = await Network().serverPost("backups/create", message);

    if (res.item1) {
      return res.item2;
    } else {
      return HttpStatus.badRequest;
    }
  } catch (e) {
    Logger().e(e);
    return HttpStatus.badRequest;
  }
}

Future<int> restoreBackupRequest(String backupName) async {
  try {
    var message = RestoreBackupRequest(authToken: await NetworkAuth().getToken(), backupName: backupName).toJson();
    var res = await Network().serverPost("backups/restore", message);

    if (res.item1) {
      return res.item2;
    } else {
      return HttpStatus.badRequest;
    }
  } catch (e) {
    Logger().e(e);
    return HttpStatus.badRequest;
  }
}

Future<int> deleteBackupRequest(String backupName) async {
  try {
    var message = DeleteBackupRequest(authToken: await NetworkAuth().getToken(), backupName: backupName).toJson();
    var res = await Network().serverPost("backups/delete", message);

    if (res.item1) {
      return res.item2;
    } else {
      return HttpStatus.badRequest;
    }
  } catch (e) {
    Logger().e(e);
    return HttpStatus.badRequest;
  }
}

Future<Tuple2<int, Uint8List>> downloadBackupRequest(String backupName) async {
  try {
    var message = DownloadBackupRequest(authToken: await NetworkAuth().getToken(), backupName: backupName).toJson();
    var res = await Network().serverPost("backups/download", message);

    if (res.item1 && res.item3.isNotEmpty) {
      var backup = DownloadBackupResponse.fromJson(res.item3);

      // convert to bytes
      if (backup.data == null) {
        return Tuple2(res.item2, Uint8List(0));
      } else {
        Uint8List bytes = Uint8List.fromList(backup.data!);
        return Tuple2(res.item2, bytes);
      }
    } else {
      return Tuple2(res.item2, Uint8List(0));
    }
  } catch (e) {
    Logger().e(e);
    return Tuple2(HttpStatus.badRequest, Uint8List(0));
  }
}

Future<int> uploadRestoreBackupRequest(String backupName, Uint8List data) async {
  try {
    var message = UploadBackupRequest(authToken: await NetworkAuth().getToken(), data: data, fileName: backupName).toJson();
    var res = await Network().serverPost("backups/upload_restore", message);

    if (res.item1) {
      return res.item2;
    } else {
      return HttpStatus.badRequest;
    }
  } catch (e) {
    Logger().e(e);
    return HttpStatus.badRequest;
  }
}
