import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';

class TmsToolBarEventTitle extends StatefulWidget {
  final double fontSize;
  const TmsToolBarEventTitle({
    Key? key,
    this.fontSize = 20,
  }) : super(key: key);

  @override
  State<TmsToolBarEventTitle> createState() => _TmsToolBarEventTitleState();
}

class _TmsToolBarEventTitleState extends State<TmsToolBarEventTitle> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  String _title = '';

  set setTitle(String title) {
    if (_title != title && mounted) {
      setState(() {
        _title = title;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    onEventUpdate((event) {
      setTitle = event.name;
    });

    getEvent().then((event) {
      setTitle = event.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _title,
      style: TextStyle(
        fontSize: widget.fontSize,
        // fontWeight: FontWeight.bold,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
