import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/schema/tms_schema.dart';

class DropdownPod extends StatefulWidget {
  final JudgingPod pod;
  final JudgingSession session;
  final Function(JudgingSession) onPodUpdate;
  const DropdownPod({
    Key? key,
    required this.pod,
    required this.session,
    required this.onPodUpdate,
  }) : super(key: key);

  @override
  State<DropdownPod> createState() => _DropdownPodState();
}

class _DropdownPodState extends State<DropdownPod> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  Event? _event;
  final List<String> _podOptions = [];

  void _setPodOptions() {
    if (_event != null) {
      _podOptions.clear();
      List<String> currentPods = widget.session.judgingPods.map((e) => e.pod).toList();
      for (var pod in _event!.pods) {
        if (!currentPods.contains(pod)) {
          _podOptions.add(pod);
        }
      }
    }
  }

  void setTableOptions() {
    if (mounted) {
      setState(() {
        _setPodOptions();
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

  Widget dropdownPodSearch() {
    return DropdownSearch<String>(
      popupProps: const PopupProps.menu(
        showSearchBox: true,
      ),
      items: _podOptions,
      dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Pod",
          hintText: "Select Pod",
        ),
      ),
      onChanged: (s) {
        if (s != null) {
          final index = widget.session.judgingPods.indexWhere((t) => t.teamNumber == widget.pod.teamNumber);
          if (index != -1) {
            JudgingSession updatedSession = widget.session;
            setState(() {
              updatedSession.judgingPods[index].pod = s;
              widget.pod.pod = s;
            });
            widget.onPodUpdate(updatedSession);
          }
        }
      },
      selectedItem: widget.pod.pod,
    );
  }

  @override
  Widget build(BuildContext context) {
    return dropdownPodSearch();
  }
}
