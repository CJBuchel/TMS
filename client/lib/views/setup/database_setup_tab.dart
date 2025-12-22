import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/generated/api/tournament.pbgrpc.dart';
import 'package:tms_client/helpers/grpc_call_wrapper.dart';
import 'package:tms_client/hooks/use_tournament_updater.dart';
import 'package:tms_client/providers/tournament_provider.dart';
import 'package:tms_client/views/setup/common/locked_button_setting.dart';
import 'package:tms_client/views/setup/common/settings_page_layout.dart';
import 'package:tms_client/views/setup/common/text_field_setting.dart';
import 'package:tms_client/widgets/dialogs/confirm_dialog.dart';

class DatabaseSetupTab extends HookConsumerWidget {
  final AsyncValue<StreamTournamentResponse> tournament;
  const DatabaseSetupTab({super.key, required this.tournament});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateTournament = useTournamentUpdater(ref);

    final intervalController = useTextEditingController();
    final retainBackupsController = useTextEditingController();

    // Update text controllers when tournament data changes
    useEffect(
      () {
        if (tournament.value != null) {
          intervalController.text = tournament.value!.tournament.backupInterval
              .toString();
          retainBackupsController.text = tournament
              .value!
              .tournament
              .retainBackups
              .toString();
        }
        return null;
      },
      [
        tournament.value?.tournament.backupInterval,
        tournament.value?.tournament.retainBackups,
      ],
    );

    return SettingsPageLayout(
      title: 'Database Setup',
      subtitle: 'Configure the database settings',
      children: [
        TextFieldSetting(
          label: 'Backup Interval (minutes)',
          description: 'The interval between database backups in minutes.',
          controller: intervalController,
          hintText: 'Enter interval (mins)',
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          keyboardType: TextInputType.number,
          onUpdate: () async {
            final value = int.tryParse(intervalController.text);
            if (value != null) {
              await updateTournament(
                tournament.value!.tournament,
                (t) => t.backupInterval = value,
              );
            }
          },
        ),
        const SizedBox(height: 24),
        TextFieldSetting(
          label: 'Retain Backups',
          description: 'Number of backups to keep.',
          controller: retainBackupsController,
          hintText: 'Enter number of backups to retain',
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          keyboardType: TextInputType.number,
          onUpdate: () async {
            final value = int.tryParse(retainBackupsController.text);
            if (value != null) {
              await updateTournament(
                tournament.value!.tournament,
                (t) => t.retainBackups = value,
              );
            }
          },
        ),
        const SizedBox(height: 24),
        LockedButtonSetting.danger(
          label: 'Purge Database',
          description:
              'Permanently delete all tournament data from the database.',
          actionButtonLabel: 'Purge',
          actionIcon: Icons.delete_forever,
          noticeMessage:
              'WARNING: This will permanently delete ALL tournament data including matches, teams, schedules, and settings. This action cannot be undone!',
          onAction: () {
            ConfirmDialog.error(
              title: 'Confirm Database Purge',
              message: const Text(
                'Are you absolutely sure you want to purge the entire database? This will delete all data and cannot be undone.',
              ),
              onConfirmAsyncGrpc: () async {
                final req = DeleteTournamentRequest();
                return await callGrpcEndpoint(
                  () =>
                      ref.read(tournamentServiceProvider).deleteTournament(req),
                );
              },
              showResultDialog: true,
              successMessage: const Text('Database purged successfully!'),
            ).show(context);
          },
        ),
      ],
    );
  }
}
