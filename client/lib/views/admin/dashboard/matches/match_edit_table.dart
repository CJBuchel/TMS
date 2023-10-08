import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/schema/tms_schema.dart';

class MatchEditTable extends StatefulWidget {
  const MatchEditTable({Key? key}) : super(key: key);

  @override
  State<MatchEditTable> createState() => _MatchTableState();
}

class _MatchTableState extends State<MatchEditTable> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  List<GameMatch> _matches = [];
  List<Team> _teams = [];

  set setMatches(List<GameMatch> value) {
    if (mounted) {
      setState(() {
        _matches = value;
      });
    }
  }

  set setMatch(GameMatch match) {
    if (mounted) {
      // find match if exists
      final index = _matches.indexWhere((m) => m.matchNumber == match.matchNumber);
      if (index != -1) {
        setState(() {
          _matches[index] = match;
        });
      } else {
        setState(() {
          _matches.add(match);
        });
      }
    }
  }

  set setTeams(List<Team> teams) {
    if (mounted) {
      setState(() {
        _teams = teams;
      });
    }
  }

  set setTeam(Team team) {
    if (mounted) {
      // find team if exists
      final index = _teams.indexWhere((t) => t.teamNumber == team.teamNumber);
      if (index != -1) {
        setState(() {
          _teams[index] = team;
        });
      } else {
        setState(() {
          _teams.add(team);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // live setters
    onMatchesUpdate((m) => setMatches = m);
    onMatchUpdate((m) => setMatch = m);
    onTeamsUpdate((t) => setTeams = t);
    onTeamUpdate((t) => setTeam = t);
  }

  Widget _topButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.refresh, color: Colors.orange),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.add, color: Colors.green),
        ),
      ],
    );
  }

  Widget _getTable() {
    return const Center(child: Text('@TODO Table'));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: ((context, constraints) {
      return Column(
        children: [
          SizedBox(
            height: 100,
            child: _topButtons(),
          ),

          // main table
          Expanded(child: _getTable()),
        ],
      );
    }));
  }
}
