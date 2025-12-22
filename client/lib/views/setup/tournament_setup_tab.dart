import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/generated/api/schedule.pbgrpc.dart';
import 'package:tms_client/generated/api/tournament.pbgrpc.dart';
import 'package:tms_client/generated/api/user.pbgrpc.dart';
import 'package:tms_client/helpers/grpc_call_wrapper.dart';
import 'package:tms_client/hooks/use_tournament_updater.dart';
import 'package:tms_client/providers/auth_provider.dart';
import 'package:tms_client/providers/schedule_provider.dart';
import 'package:tms_client/utils/grpc_result.dart';
import 'package:tms_client/views/setup/common/file_upload_setting.dart';
import 'package:tms_client/views/setup/common/locked_text_field_setting.dart';
import 'package:tms_client/views/setup/common/settings_page_layout.dart';
import 'package:tms_client/views/setup/common/text_field_setting.dart';
import 'package:tms_client/widgets/dialogs/confirm_dialog.dart';
import 'package:tms_client/widgets/dialogs/popup_dialog.dart';

class TournamentSetupTab extends HookConsumerWidget {
  final AsyncValue<StreamTournamentResponse> tournament;
  const TournamentSetupTab({super.key, required this.tournament});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateTournament = useTournamentUpdater(ref);

    Future<GrpcResult<UploadScheduleCsvResponse>> uploadSchedule(
      Uint8List bytes,
    ) async {
      final req = UploadScheduleCsvRequest(csvData: bytes);
      return await callGrpcEndpoint(
        () => ref.read(scheduleServiceProvider).uploadScheduleCsv(req),
      );
    }

    final nameController = useTextEditingController();
    final adminPasswordController = useTextEditingController();
    final eventKeyController = useTextEditingController();

    // Update text controllers when tournament data changes
    useEffect(
      () {
        if (tournament.value != null) {
          nameController.text = tournament.value!.tournament.name;
          eventKeyController.text = tournament.value!.tournament.eventKey;
        }
        return null;
      },
      [
        tournament.value?.tournament.name,
        tournament.value?.tournament.eventKey,
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
            await updateTournament(
              tournament.value!.tournament,
              (t) => t.name = nameController.text,
            );
          },
        ),
        const SizedBox(height: 24),
        TextFieldSetting(
          label: 'Admin Password',
          description: 'Update the admin password for this event',
          controller: adminPasswordController,
          hintText: 'Enter password',
          obscureText: true,
          onUpdate: () async {
            final res = await callGrpcEndpoint(
              () => ref
                  .read(userServiceProvider)
                  .updateAdminPassword(
                    UpdateAdminPasswordRequest(
                      password: adminPasswordController.text,
                    ),
                  ),
            );

            // Show error dialog if request failed
            if (context.mounted) {
              PopupDialog.fromGrpcStatus(result: res).show(context);
            }
          },
        ),
        const SizedBox(height: 24),
        FileUploadSetting(
          label: 'Schedule Upload',
          description: 'Upload a CSV file containing the tournament schedule',
          allowedExtensions: ['csv'],
          uploadButtonLabel: 'Upload',
          onUpload: (file) async {
            if (file.bytes != null) {
              ConfirmDialog.warn(
                title: 'Confirm Upload',
                message: const Text(
                  'Uploading a schedule can have impacts on existing data integrity',
                ),
                onConfirmAsyncGrpc: () async {
                  return await uploadSchedule(file.bytes!);
                },
                showResultDialog: true,
                successMessage: const Text('Schedule uploaded successfully!'),
              ).show(context);
            }
          },
        ),
        const SizedBox(height: 24),
        LockedTextFieldSetting.danger(
          label: 'Event Key',
          description: 'Unique identifier for this tournament event',
          controller: eventKeyController,
          hintText: 'Enter event key',
          noticeMessage:
              'WARNING: Changing the event key can cause data inconsistencies and break integrations. Only modify if absolutely necessary.',
          onUpdate: () async {
            await updateTournament(
              tournament.value!.tournament,
              (t) => t.eventKey = eventKeyController.text,
            );
          },
        ),
      ],
    );
  }
}
