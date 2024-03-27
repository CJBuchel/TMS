import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/dashboard/team_data/data_table.dart';
import 'package:tms/views/shared/dashboard/team_data/td_table_types.dart';
import 'package:tms/views/shared/dashboard/team_data/team_data_header.dart';

class TeamData extends StatefulWidget {
  const TeamData({Key? key}) : super(key: key);

  @override
  State<TeamData> createState() => _TeamDataState();
}

class _TeamDataState extends State<TeamData> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  final ValueNotifier<Event?> _event = ValueNotifier(null);
  final ValueNotifier<List<Team>> _teams = ValueNotifier<List<Team>>([]);
  final ValueNotifier<List<GameMatch>> _matches = ValueNotifier<List<GameMatch>>([]);
  final ValueNotifier<List<JudgingSession>> _judgingSessions = ValueNotifier<List<JudgingSession>>([]);

  final ValueNotifier<List<TDColumn>> _columns = ValueNotifier<List<TDColumn>>([]);
  final ValueNotifier<List<TDRow>> _rows = ValueNotifier<List<TDRow>>([]);

  set _setTeams(List<Team> teams) => _teams.value = teams;
  set _setMatches(List<GameMatch> matches) => _matches.value = matches;
  set _setJudgingSessions(List<JudgingSession> judgingSessions) => _judgingSessions.value = judgingSessions;

  List<TDColumn> _getColumns(int rounds) {
    List<TDColumn> columns = [
      TDColumn(
        label: 'Rank',
        show: true,
        flex: 1,
      ),
      TDColumn(
        label: 'Team #',
        show: true,
        flex: 1,
      ),
      TDColumn(
        label: 'Team Name',
        show: true,
        flex: 2,
      ),
    ];

    for (int i = 0; i < rounds; i++) {
      columns.addAll([
        TDColumn(
          label: 'R${i + 1} Score',
          show: true,
          flex: 1,
        ),
        TDColumn(
          label: 'R${i + 1} GP',
          show: true,
          flex: 1,
        ),
        TDColumn(
          label: 'R${i + 1} Pub Comment',
          show: false,
          flex: 2,
        ),
        TDColumn(
          label: 'R${i + 1} Priv Comment',
          show: false,
          flex: 2,
        ),
      ]);
    }

    return columns;
  }

  set _setEvent(Event e) {
    _event.value = e;
  }

  void _toggleTheme() {
    setState(() {});
  }

  void _setColumns() {
    if (_event.value != null) {
      _columns.value = _getColumns(_event.value!.eventRounds);
    }
  }

  void _setData() async {
    getTeams().then((teams) {
      _setTeams = teams;
    });
    getMatches().then((matches) => _setMatches = matches);
    getJudgingSessions().then((judgingSessions) => _setJudgingSessions = judgingSessions);
    getEvent().then((event) {
      _setEvent = event;
      _setColumns();
    });
  }

  @override
  void initState() {
    super.initState();

    onEventUpdate((e) => _setEvent = e);
    onTeamsUpdate((t) => _setTeams = t);
    onMatchesUpdate((m) => _setMatches = m);
    onJudgingSessionsUpdate((js) => _setJudgingSessions = js);

    AppTheme.isDarkThemeNotifier.addListener(_toggleTheme);
    _event.addListener(_setColumns);

    Future.delayed(const Duration(milliseconds: 500), () {
      _setData();
    });
  }

  @override
  void dispose() {
    AppTheme.isDarkThemeNotifier.removeListener(_toggleTheme);
    _event.removeListener(_setColumns);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ValueListenableBuilder(
          valueListenable: _columns,
          builder: (context, columns, child) {
            return ValueListenableBuilder(
              valueListenable: _event,
              builder: (context, event, child) {
                if (event == null) {
                  return const Center(child: Text("Loading..."));
                } else {
                  return Column(
                    children: [
                      // main header
                      TeamDataHeader(
                        columns: _columns,
                        rows: _rows,
                      ),

                      // table
                      Expanded(
                        child: TeamDataTable(
                          rounds: event.eventRounds,
                          teams: _teams,
                          columns: columns,
                          generatedRows: _rows,
                        ),
                      ),
                    ],
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}
