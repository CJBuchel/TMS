import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/network/http.dart';
import 'package:tms/network/network.dart';
import 'package:tms/network/security.dart';
import 'package:tms/network/ws.dart';
import 'package:tms/requests/game_requests.dart';

class DropdownSeason extends StatefulWidget {
  final Function(String) onSelectedSeason;

  const DropdownSeason({
    Key? key,
    required this.onSelectedSeason,
  }) : super(key: key);

  @override
  State<DropdownSeason> createState() => _DropdownSeasonState();
}

class _DropdownSeasonState extends State<DropdownSeason> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  List<String> _dropdownSeasons = [];
  String _selectedSeason = "";

  void setAvailableSeasons(List<String> seasons) {
    if (mounted) {
      seasons.sort((a, b) => int.tryParse(b)?.compareTo(int.tryParse(a) ?? 0) ?? 0);
      var selectedSeason = (_selectedSeason.isEmpty) ? seasons.first : _selectedSeason;
      setState(() {
        _dropdownSeasons = seasons;
        _selectedSeason = selectedSeason;
      });
    }
  }

  void checkAvailableSeasons() async {
    if (await Network().isConnected()) {
      getSeasonsRequest().then((res) {
        if (res.item1 == HttpStatus.ok) {
          setAvailableSeasons(res.item2);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    onEventUpdate((event) {
      if (_dropdownSeasons.contains(event.season)) {
        setState(() {
          _selectedSeason = event.season;
        });
      }
    });

    checkAvailableSeasons();
    NetworkHttp().httpState.addListener(checkAvailableSeasons);
    NetworkWebSocket().wsState.addListener(checkAvailableSeasons);
    NetworkSecurity().securityState.addListener(checkAvailableSeasons);
  }

  @override
  void dispose() {
    NetworkHttp().httpState.removeListener(checkAvailableSeasons);
    NetworkWebSocket().wsState.removeListener(checkAvailableSeasons);
    NetworkSecurity().securityState.removeListener(checkAvailableSeasons);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedSeason,
      hint: const Text("Select Season"),
      onChanged: (String? value) {
        setState(() {
          _selectedSeason = value ?? "";
          widget.onSelectedSeason(_selectedSeason);
        });
      },
      items: _dropdownSeasons.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
