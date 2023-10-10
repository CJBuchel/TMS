import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/schema/tms_schema.dart';

class DropdownTable extends StatefulWidget {
  final OnTable onTable;
  final GameMatch match;
  final Function(GameMatch) onTableUpdate;
  const DropdownTable({
    Key? key,
    required this.onTable,
    required this.match,
    required this.onTableUpdate,
  }) : super(key: key);

  @override
  State<DropdownTable> createState() => _DropdownTableState();
}

class _DropdownTableState extends State<DropdownTable> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  Event? _event;
  final List<String> _tableOptions = [];

  void _setTableOptions() {
    if (_event != null) {
      _tableOptions.clear();

      List<String> currentTables = widget.match.matchTables.map((e) => e.table).toList();

      for (var table in _event!.tables) {
        if (!currentTables.contains(table)) {
          _tableOptions.add(table);
        }
      }
    }
  }

  void setTableOptions() {
    if (mounted) {
      setState(() {
        _setTableOptions();
      });
    }
  }

  void setEvent(Event event) {
    if (mounted) {
      setState(() {
        _event = event;
      });
      setTableOptions();
    }
  }

  @override
  void initState() {
    super.initState();
    onEventUpdate((event) => setEvent(event));
  }

  Widget dropdownTableSearch() {
    return DropdownSearch<String>(
      popupProps: const PopupProps.menu(
        showSelectedItems: true,
      ),
      items: _tableOptions,
      dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Table",
          hintText: "Select Table",
        ),
      ),
      onChanged: (s) {
        if (s != null) {
          // find the table in _updatedMatch and update it
          final index = widget.match.matchTables.indexWhere((t) => t.teamNumber == widget.onTable.teamNumber);
          if (index != -1) {
            GameMatch updatedMatch = widget.match;
            setState(() {
              updatedMatch.matchTables[index].table = s;
              widget.onTable.table = s;
            });
            widget.onTableUpdate(updatedMatch);
          }
        }
      },
      selectedItem: widget.onTable.table,
    );
  }

  @override
  Widget build(BuildContext context) {
    return dropdownTableSearch();
  }
}
