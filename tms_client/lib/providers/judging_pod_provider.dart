import 'package:echo_tree_flutter/widgets/echo_tree_provider.dart';
import 'package:tms/generated/infra/database_schemas/judging_pod.dart';
import 'package:collection/collection.dart';
import 'package:tms/services/judging_pod_service.dart';

class JudgingPodProvider extends EchoTreeProvider<String, JudgingPod> {
  final JudgingPodService _service = JudgingPodService();

  JudgingPodProvider()
      : super(
          tree: ":judging:pods",
          fromJsonString: (json) => JudgingPod.fromJsonString(json: json),
        );

  List<JudgingPod> get podsByName {
    // sort by name/compare alphabetically
    return this.items.values.toList()..sort((a, b) => a.podName.compareTo(b.podName));
  }

  List<JudgingPod> get pods => podsByName;

  List<String> get podNames => podsByName.map((e) => e.podName).toList();

  String? getIdFromPodName(String podName) {
    return this.items.keys.firstWhereOrNull((key) => this.items[key]?.podName == podName);
  }

  Future<int> insertPod(String? podId, String pod) async {
    return _service.insertPod(podId, pod);
  }

  Future<int> removePod(String podId) async {
    return _service.removePod(podId);
  }
}
