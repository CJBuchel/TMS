import 'dart:io';

import 'package:tms/generated/infra/network_schemas/judging_pod_requests.dart';
import 'package:tms/network/network.dart';
import 'package:tms/utils/logger.dart';

class JudgingPodService {
  Future<int> insertPod(String? podId, String pod) async {
    try {
      var request = JudgingPodInsertRequest(
        podId: podId,
        pod: pod,
      ).toJsonString();
      var response = await Network().networkPost("/judging/pods/insert_pod", request);
      if (response.$1) {
        TmsLogger().i("Inserted pod $pod");
        return HttpStatus.ok;
      } else {
        return response.$2;
      }
    } catch (e) {
      TmsLogger().e("Error: $e");
      return HttpStatus.badRequest;
    }
  }

  Future<int> removePod(String podId) async {
    try {
      var request = JudgingPodRemoveRequest(podId: podId).toJsonString();
      var response = await Network().networkDelete("/judging/pods/remove_pod", request);
      if (response.$1) {
        TmsLogger().i("Removed pod: $podId");
        return HttpStatus.ok;
      } else {
        return response.$2;
      }
    } catch (e) {
      TmsLogger().e("Error: $e");
      return HttpStatus.badRequest;
    }
  }
}
