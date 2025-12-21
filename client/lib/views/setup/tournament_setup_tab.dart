import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/generated/api/schedule.pbgrpc.dart';
import 'package:tms_client/generated/api/tournament.pbgrpc.dart';
import 'package:tms_client/generated/db/db.pb.dart';
import 'package:tms_client/helpers/grpc_call_wrapper.dart';
import 'package:tms_client/providers/schedule_provider.dart';
import 'package:tms_client/providers/tournament_provider.dart';
import 'package:tms_client/utils/grpc_result.dart';
import 'package:tms_client/views/setup/common/dropdown_setting.dart';
import 'package:tms_client/views/setup/common/file_upload_setting.dart';
import 'package:tms_client/views/setup/common/locked_text_field_setting.dart';
import 'package:tms_client/views/setup/common/settings_page_layout.dart';
import 'package:tms_client/views/setup/common/text_field_setting.dart';
import 'package:tms_client/widgets/dialogs/popup_dialog.dart';

// enum Season {
//   fall,
//   winter,
//   spring,
//   summer;

//   String get displayName {
//     return name[0].toUpperCase() + name.substring(1);
//   }
// }

class TournamentSetupTab extends HookConsumerWidget {
  const TournamentSetupTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournament = ref.watch(tournamentStreamProvider);

    Future<void> updateTournament(void Function(Tournament) modify) async {
      final updated = tournament.value!.tournament.deepCopy();
      modify(updated);

      final req = SetTournamentRequest(tournament: updated);
      final res = await callGrpcEndpoint(
        () => ref.read(tournamentServiceProvider).setTournament(req),
      );

      if (context.mounted && res is GrpcFailure) {
        PopupDialog.fromGrpcStatus(result: res).show(context);
      }
    }

    Future<void> uploadSchedule(Uint8List bytes) async {
      final req = UploadScheduleCsvRequest(csvData: bytes);
      final res = await callGrpcEndpoint(
        () => ref.read(scheduleServiceProvider).uploadScheduleCsv(req),
      );

      if (context.mounted && res is GrpcFailure) {
        PopupDialog.fromGrpcStatus(result: res).show(context);
      }
    }

    final nameController = useTextEditingController();
    final eventKeyController = useTextEditingController();
    final selectedSeason = useState<Season>(Season.SEASON_2025);

    // Update text controllers when tournament data changes
    useEffect(
      () {
        if (tournament.value != null) {
          nameController.text = tournament.value!.tournament.name;
          eventKeyController.text = tournament.value!.tournament.eventKey;
          selectedSeason.value = tournament.value!.tournament.season;
        }
        return null;
      },
      [
        tournament.value?.tournament.name,
        tournament.value?.tournament.eventKey,
        tournament.value?.tournament.season,
      ],
    );

    return SettingsPageLayout(
      title: 'Tournament Setup',
      subtitle: 'Configure your tournament settings',
      children: [
        TextFieldSetting(
          label: 'Tournament Name',
          description: 'The display name for your tournament',
          controller: nameController,
          hintText: 'Enter tournament name',
          onUpdate: () async {
            await updateTournament((t) {
              t.name = nameController.text;
            });
          },
        ),
        const SizedBox(height: 24),
        FileUploadSetting(
          label: 'Schedule Import',
          description: 'Upload a CSV file containing the tournament schedule',
          allowedExtensions: ['csv'],
          uploadButtonLabel: 'Import',
          onUpload: (file) async {
            if (file.bytes != null) {
              uploadSchedule(file.bytes!);
            }
          },
        ),
        const SizedBox(height: 24),
        DropdownSetting<Season>(
          label: 'Season',
          description: 'The season this tournament takes place in',
          value: selectedSeason.value,
          items: Season.values.map((season) {
            return DropdownMenuItem(value: season, child: Text(season.name));
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              selectedSeason.value = value;
            }
          },
          onUpdate: () async {
            await updateTournament((t) {
              t.season = selectedSeason.value;
            });
          },
        ),
        const SizedBox(height: 24),
        LockedTextFieldSetting(
          label: 'Event Key',
          description: 'Unique identifier for this tournament event',
          controller: eventKeyController,
          hintText: 'Enter event key',
          useErrorStyle: true,
          warningMessage:
              'WARNING: Changing the event key can cause data inconsistencies and break integrations. Only modify if absolutely necessary.',
          onUpdate: () async {
            await updateTournament((t) {
              t.eventKey = eventKeyController.text;
            });
          },
        ),
      ],
    );
  }
}
