import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:tms/generated/infra/network_schemas/backup_requests.dart';
import 'package:tms/network/http.dart';
import 'package:tms/network/network.dart';
import 'package:tms/providers/local_storage_provider.dart';
import 'package:tms/utils/logger.dart';

class BackupsService {
  Future<(int, BackupGetNamesResponse?)> getBackups() async {
    try {
      var response = await Network().networkGet("/backup/names");

      if (response.$1) {
        BackupGetNamesResponse backupResponse = BackupGetNamesResponse.fromJsonString(json: response.$3);
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

  Future<int> restoreBackup(String backupName) async {
    try {
      var response = await Network().networkPost(
        "/backup/restore",
        BackupRestoreRequest(fileName: backupName).toJsonString(),
      );

      if (response.$1) {
        return HttpStatus.ok;
      } else {
        return response.$2;
      }
    } catch (e) {
      TmsLogger().e("Error: $e");
      return HttpStatus.badRequest;
    }
  }

  Future<int> createBackup() async {
    try {
      var response = await Network().networkPost("/backup/create", "");

      if (response.$1) {
        return HttpStatus.ok;
      } else {
        return response.$2;
      }
    } catch (e) {
      TmsLogger().e("Error: $e");
      return HttpStatus.badRequest;
    }
  }

  Future<int> downloadBackup(String backupName) async {
    try {
      String addr = TmsLocalStorageProvider().serverAddress;
      String downloadUrl = "$addr/backup/download/$backupName";
      await FileSaver.instance.saveFile(
        name: backupName,
        link: LinkDetails(
          headers: HttpController().authHeaders,
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
