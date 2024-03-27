import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/event_local_db.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/dashboard/pods/pods_table.dart';

class Pods extends StatefulWidget {
  const Pods({Key? key}) : super(key: key);

  @override
  State<Pods> createState() => _PodsState();
}

class _PodsState extends State<Pods> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  final ValueNotifier<Event> _eventNotifier = ValueNotifier<Event>(EventLocalDB.singleDefault());

  set _setEvent(Event e) {
    _eventNotifier.value = e;
  }

  @override
  void initState() {
    super.initState();
    getEvent().then((e) => _setEvent = e);
    onEventUpdate((e) => _setEvent = e);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constrains) {
        return Column(
          children: [
            Expanded(
              child: PodsTable(event: _eventNotifier),
            ),
          ],
        );
      },
    );
  }
}
