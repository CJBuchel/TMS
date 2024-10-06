import 'dart:io';

import 'package:tms/generated/infra/network_schemas/backup_requests.dart';
import 'package:tms/network/network.dart';
import 'package:tms/utils/logger.dart';

class BackupsService {
  Future<(int, BackupResponse?)> get_backups() async {
    try {
      var response = await Network().networkGet("/backup/names");

      if (response.$1) {
        BackupResponse backupResponse = BackupResponse.fromJsonString(json: response.$3);
        TmsLogger().i("BackupResponse: $backupResponse");
        return (HttpStatus.ok, backupResponse);
      } else {
        return (response.$2, null);
      }
    } catch (e) {
      TmsLogger().e("Error: $e");
      return (HttpStatus.badRequest, null);
    }
  }
}
