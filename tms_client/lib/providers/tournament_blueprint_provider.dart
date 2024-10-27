import 'dart:io';

import 'package:echo_tree_flutter/widgets/echo_tree_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tms/generated/infra/database_schemas/tournament_blueprint.dart';
import 'package:tms/generated/infra/fll_infra/fll_blueprint.dart';
import 'package:tms/generated/infra/network_schemas/tournament_config_requests.dart';
import 'package:tms/providers/tournament_config_provider.dart';
import 'package:tms/services/tournament_blueprint_service.dart';

class TournamentBlueprintProvider extends EchoTreeProvider<String, TournamentBlueprint> {
  TournamentBlueprintService _service = TournamentBlueprintService();
  TournamentConfigProvider _configProvider = TournamentConfigProvider();

  String _season = "";
  BlueprintType _blueprintType = BlueprintType.agnostic;

  String get season => _season;
  BlueprintType get blueprintType => _blueprintType;
  FllBlueprint get blueprint => getBlueprint(_season).blueprint;

  void _updateBlueprints() {
    _season = _configProvider.season;
    _blueprintType = _configProvider.blueprintType;
    notifyListeners();
  }

  TournamentBlueprintProvider()
      : super(
          tree: ":tournament:blueprint",
          fromJsonString: (json) => TournamentBlueprint.fromJsonString(json: json),
        ) {
    _configProvider.addListener(_updateBlueprints);
  }

  @override
  void dispose() {
    _configProvider.removeListener(_updateBlueprints);
    super.dispose();
  }

  FilePickerResult? result;

  List<TournamentBlueprint> get blueprints {
    return this.items.values.toList();
  }

  List<String> get blueprintTitles {
    return this.items.map((key, value) => MapEntry(key, value.title)).values.toList();
  }

  TournamentBlueprint getBlueprint(String blueprintTitle) {
    // find blueprint from blueprint title
    try {
      return blueprints.firstWhere((t) => t.title == blueprintTitle);
    } catch (e) {
      return const TournamentBlueprint(
        title: 'N/A',
        blueprint: FllBlueprint(
          robotGameQuestions: [],
          robotGameMissions: [],
        ),
      );
    }
  }

  Future<void> selectBlueprint() async {
    // file picker
    result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      notifyListeners();
    }
  }

  Future<int> uploadBlueprint() async {
    if (result != null) {
      try {
        return await _service.uploadBlueprint(result!.files.first.bytes!);
      } catch (e) {
        return HttpStatus.notAcceptable;
      }
    } else {
      return HttpStatus.badRequest;
    }
  }
}
