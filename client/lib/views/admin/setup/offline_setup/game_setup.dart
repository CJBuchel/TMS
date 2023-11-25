import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tms/views/shared/dropdowns/drop_down_season.dart';

class GameSetup extends StatelessWidget {
  // season
  final TextEditingController eventNameController;
  final TextEditingController selectedSeasonController;
  final TextEditingController roundNumberController;
  final TextEditingController endgameTimerCountdownController;
  final TextEditingController timerCountdownController;

  const GameSetup({
    Key? key,
    required this.eventNameController,
    required this.selectedSeasonController,
    required this.roundNumberController,
    required this.endgameTimerCountdownController,
    required this.timerCountdownController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Select Season
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
          child: Text("Select Season", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),

        // season select
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
          child: DropdownSeason(
            onSelectedSeason: (season) {
              selectedSeasonController.text = season;
            },
          ),
        ),

        // name of event
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
          child: TextField(
            controller: eventNameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Event Name',
              hintText: 'Enter Event Name: e.g `Curtin Championship`',
            ),
          ),
        ),

        // round setup
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
          child: TextField(
            controller: roundNumberController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Rounds',
              hintText: 'Enter Rounds: e.g `3` rounds',
            ),
          ),
        ),

        // endgame timer setup
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
          child: TextField(
            controller: endgameTimerCountdownController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Endgame Timer Countdown',
              hintText: 'Enter Timer Countdown: e.g `30` seconds',
            ),
          ),
        ),

        // main timer setup
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
          child: TextField(
            controller: timerCountdownController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Timer Countdown',
              hintText: 'Enter Timer Countdown: e.g `150` seconds',
            ),
          ),
        ),
      ],
    );
  }
}
