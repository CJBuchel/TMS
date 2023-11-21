import 'package:flutter/material.dart';
import 'package:tms/views/referee_scoring/table_setup.dart';

class ScoringHeaderPopupMenu extends StatelessWidget {
  final ValueNotifier<bool> lockedNotifier;
  final Function(String table, bool force) sendTableLoadedMatch;
  final Function(bool locked) changeLocked;

  const ScoringHeaderPopupMenu({
    Key? key,
    required this.lockedNotifier,
    required this.sendTableLoadedMatch,
    required this.changeLocked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(
        Icons.more_horiz,
        color: Colors.white,
      ),
      itemBuilder: (context) => [
        // switch table item
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text("Switch Table"),
            onTap: () {
              RefereeTableUtil.setTable("").then((v) {
                Navigator.pop(context);
                Navigator.popAndPushNamed(context, "/referee/table_setup");
              });
            },
          ),
        ),

        // lock/unlock item
        PopupMenuItem(
          child: ValueListenableBuilder(
            valueListenable: lockedNotifier,
            builder: (context, locked, _) {
              return ListTile(
                leading: locked ? const Icon(Icons.lock_open) : const Icon(Icons.lock),
                title: locked ? const Text("Unlock") : const Text("Lock"),
                onTap: () {
                  RefereeTableUtil.getTable().then((thisTable) {
                    sendTableLoadedMatch(thisTable, true);
                    changeLocked(!locked); // will also need to call onLock later
                    Navigator.pop(context);
                  });
                },
              );
            },
          ),
        ),

        // schedule item
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text("Schedule"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/referee/schedule");
            },
          ),
        ),

        // rule book
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.book),
            title: const Text("Rule Book"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/referee/rule_book");
            },
          ),
        ),
      ],
    );
  }
}
