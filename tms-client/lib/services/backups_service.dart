import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:tms/generated/infra/network_schemas/backup_requests.dart';
import 'package:tms/network/network.dart';
import 'package:tms/providers/local_storage_provider.dart';
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

  Future<int> downloadBackup(String backupName) async {
    try {
      String addr = TmsLocalStorageProvider().serverAddress;
      String downloadUrl = "$addr/backup/download/$backupName";
      await FileSaver.instance.saveFile(
        name: backupName,
        link: LinkDetails(
          headers: {
            "X-Client-Id": TmsLocalStorageProvider().uuid,
            "X-Auth-Token": TmsLocalStorageProvider().authToken,
          },
          link: downloadUrl,
        ),
        mimeType: MimeType.zip,
      );

      return HttpStatus.ok;
    } catch (e) {
      TmsLogger().e("Error: $e");
      return HttpStatus.badRequest;
    }
  }
}
