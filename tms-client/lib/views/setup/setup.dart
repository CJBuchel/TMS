import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:tms/views/setup/admin_password_setup.dart';
import 'package:tms/views/setup/backup_interval_setup.dart';
import 'package:tms/views/setup/endgame_timer_length_setup.dart';
import 'package:tms/views/setup/event_name_setup.dart';
import 'package:tms/views/setup/purge_event.dart';
import 'package:tms/views/setup/retain_backup_setup.dart';
import 'package:tms/views/setup/schedule_setup.dart';
import 'package:tms/views/setup/season_setup.dart';
import 'package:tms/views/setup/timer_length_setup.dart';
import 'package:tms/views/setup/blueprint_setup.dart';

class Setup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EchoTreeLifetime(
      trees: [":tournament:config", ":tournament:blueprint"],
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: SizedBox(
            width: 800,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    "System Setup",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                EventNameSetup(),
                AdminPasswordSetup(),
                BackupIntervalSetup(),
                BackupRetentionSetup(),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    "Schedule Setup",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                ScheduleSetup(),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    "Season Setup",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                SeasonSetup(),
                BlueprintSetup(),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    "Game Scoring Setup",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                TimerLengthSetup(),
                EndgameTimerLengthSetup(),

                // Purge Event
                PurgeButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
