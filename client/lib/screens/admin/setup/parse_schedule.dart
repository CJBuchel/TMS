import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tuple/tuple.dart';

String _detectEol(String input) {
  if (input.contains('\r\n')) {
    return '\r\n';
  } else if (input.contains('\n')) {
    return '\n';
  } else {
    return '\n';
  }
}

// CSV Parser
Tuple2<bool, SetupRequest?> parseSchedule(FilePickerResult result) {
  try {
    final input = result.files.single.bytes!;
    // convert bytes to string
    final csvString = String.fromCharCodes(input);

    // parse the csv string
    final eol = _detectEol(csvString);
    final rows = CsvToListConverter(eol: eol).convert(csvString);

    if (rows[0][1] != 1) {
      // check version is 1
      return const Tuple2(false, null); // @TODO, return with bad flag
    }

    // blocks (teams = 1, matches = 2, judging = 3)
    final teamBlock = <List<dynamic>>[];
    final matchBlock = <List<dynamic>>[];
    final judgingBlock = <List<dynamic>>[];

    const blockFormat = "Block Format";
    int currentBlock = 0;

    // separate into blocks
    for (var line in rows) {
      if (line[0] == blockFormat) {
        currentBlock = line[1];
        continue;
      }

      // add to respective block
      switch (currentBlock) {
        case 1:
          teamBlock.add(line);
          break;
        case 2:
          matchBlock.add(line);
          break;
        case 3:
          judgingBlock.add(line);
          break;
        default:
          break;
      }
    }

    // Parse Teams
    var teams = <Team>[];
    for (var i = 1; i < teamBlock.length; i++) {
      Team team = Team(
        coreValuesScores: [],
        gameScores: [],
        innovationProjectScores: [],
        ranking: 0,
        robotDesignScores: [],
        teamId: "",
        teamNumber: "${teamBlock[i][0]}",
        teamName: "${teamBlock[i][1]}",
        teamAffiliation: "${teamBlock[i][2]}",
      );
      teams.add(team);
    }

    // Parse tables
    var tables = <String>[];
    int numTables = matchBlock[1][1]; // number of tables
    for (var i = 0; i < numTables; i++) {
      tables.add("${matchBlock[4][i + 1]}"); // table name/color/number
    }

    // Parse Matches
    var matches = <GameMatch>[];
    for (var i = 5; i < matchBlock.length; i++) {
      String matchNumber = "${matchBlock[i][0]}";
      String startTime = "${matchBlock[i][1]}";
      String endTime = "${matchBlock[i][2]}";
      var onTables = <OnTable>[];

      // Determine teams on tables first and second
      for (var j = 3; j < matchBlock[i].length; j++) {
        if (matchBlock[i][j] != "" && matchBlock[i][j] != null) {
          onTables.add(
            OnTable(
              scoreSubmitted: false,
              teamNumber: "${matchBlock[i][j]}",
              table: tables[j - 3],
            ),
          );
        }
      }

      GameMatch match = GameMatch(
        complete: false,
        customMatch: false,
        gameMatchDeferred: false,
        startTime: startTime,
        endTime: endTime,
        matchNumber: matchNumber,
        onTableFirst: onTables[0],
        onTableSecond: onTables[1],
      );

      matches.add(match);
    }

    // Parse Event Rounds
    int numRounds = 0;
    for (var team in teams) {
      var teamNum = team.teamNumber;
      int numRoundsTeam = 0;

      // Check how many times each team participates
      for (var match in matches) {
        if (match.onTableFirst.teamNumber == teamNum || match.onTableSecond.teamNumber == teamNum) {
          numRoundsTeam++;
        }
      }

      // set number of rounds to the maximum a single team participates
      numRounds = numRoundsTeam > numRounds ? numRoundsTeam : numRounds;
    }

    // Parse Judging Pods
    var pods = <String>[];
    int numPods = judgingBlock[2][1]; // number of pods
    for (var i = 0; i < numPods; i++) {
      pods.add("${judgingBlock[4][i + 1]}"); // pod name/color/number
    }

    // Parse Judging Sessions
    var judgingSessions = <JudgingSession>[];
    for (var i = 5; i < judgingBlock.length; i++) {
      String session = "${judgingBlock[i][0]}";
      String startTime = "${judgingBlock[i][1]}";
      String endTime = "${judgingBlock[i][2]}";

      for (var j = 3; j < judgingBlock[i].length; j++) {
        if (judgingBlock[i][j] != "" && judgingBlock[i][j] != null) {
          judgingSessions.add(
            JudgingSession(
              complete: false,
              customSession: false,
              judgingSessionDeferred: false,
              startTime: startTime,
              endTime: endTime,
              session: session,
              teamNumber: "${judgingBlock[i][j]}",
              pod: pods[j - 3],
            ),
          );
        }
      }
    }

    // Parse Event
    Event event = Event(
      eventRounds: numRounds,
      name: "",
      onlineLink: OnlineLink(linked: false, tournamentId: "", tournamentToken: ""),
      pods: pods,
      season: "",
      tables: tables,
      timerLength: 150,
    );

    return Tuple2(
      true,
      SetupRequest(
        authToken: "",
        adminPassword: "",
        users: [],
        event: event,
        teams: teams,
        matches: matches,
        judgingSessions: judgingSessions,
      ),
    );
  } catch (e) {
    return const Tuple2(false, null);
  }
}
