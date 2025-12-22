import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/generated/api/tournament.pbgrpc.dart';
import 'package:tms_client/generated/db/db.pbenum.dart';
import 'package:tms_client/hooks/use_tournament_updater.dart';
import 'package:tms_client/views/setup/common/dropdown_setting.dart';
import 'package:tms_client/views/setup/common/settings_page_layout.dart';
import 'package:tms_client/views/setup/common/text_field_setting.dart';

class GameSetupTab extends HookConsumerWidget {
  final AsyncValue<StreamTournamentResponse> tournament;
  const GameSetupTab({super.key, required this.tournament});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateTournament = useTournamentUpdater(ref);

    final selectedSeason = useState<Season>(Season.SEASON_2025);
    final gameTimerLengthController = useTextEditingController();
    final endgameTimerTriggerController = useTextEditingController();

    useEffect(
      () {
        if (tournament.value != null) {
          selectedSeason.value = tournament.value!.tournament.season;
          gameTimerLengthController.text = tournament
              .value!
              .tournament
              .gameTimerLength
              .toString();
          endgameTimerTriggerController.text = tournament
              .value!
              .tournament
              .endGameTimerTrigger
              .toString();
        }
        return null;
      },
      [
        tournament.value?.tournament.season,
        tournament.value?.tournament.gameTimerLength,
        tournament.value?.tournament.endGameTimerTrigger,
      ],
    );
    return SettingsPageLayout(
      title: 'Robot Game Setup',
      subtitle: 'Configure robot game settings',
      children: [
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
            await updateTournament(
              tournament.value!.tournament,
              (t) => t.season = selectedSeason.value,
            );
          },
        ),
        const SizedBox(height: 24),
        TextFieldSetting(
          label: 'Game Timer Length',
          description: 'Game timer length in seconds',
          controller: gameTimerLengthController,
          hintText: 'Enter time (secs)',
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          keyboardType: TextInputType.number,
          onUpdate: () async {
            final value = int.tryParse(gameTimerLengthController.text);
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
          label: 'Endgame Time Trigger',
          description: 'Time in seconds when endgame is triggered',
          controller: endgameTimerTriggerController,
          hintText: 'Enter time (secs)',
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          keyboardType: TextInputType.number,
          onUpdate: () async {
            final value = int.tryParse(endgameTimerTriggerController.text);
            if (value != null) {
              await updateTournament(
                tournament.value!.tournament,
                (t) => t.backupInterval = value,
              );
            }
          },
        ),
      ],
    );
  }
}
