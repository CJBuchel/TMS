import 'dart:io';

import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/judging_pod.dart';
import 'package:tms/providers/judging_pod_provider.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/widgets/dialogs/confirm_dialogs.dart';
import 'package:tms/widgets/dialogs/confirm_future_dialog.dart';
import 'package:tms/widgets/tables/base_table.dart';
import 'package:tms/widgets/tables/edit_row_table.dart';

class JudgingPods extends StatelessWidget {
  final TextEditingController _podController = TextEditingController();

  BaseTableCell _buildCell(Widget child) {
    return BaseTableCell(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: child,
        ),
      ),
    );
  }

  List<EditTableRow> _rows(BuildContext context, List<JudgingPod> pods) {
    return pods.map((pod) {
      return EditTableRow(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
        onEdit: () {
          _podController.text = pod.podName;
          ConfirmFutureDialog(
            onStatusConfirmFuture: () {
              String? podId = Provider.of<JudgingPodProvider>(context, listen: false).getIdFromPodName(
                pod.podName,
              );
              if (podId == null) {
                TmsLogger().i("Pod ID is null");
                return Future.value(HttpStatus.notFound);
              } else {
                return Provider.of<JudgingPodProvider>(context, listen: false).insertPod(
                  podId,
                  _podController.text,
                );
              }
            },
            style: ConfirmDialogStyle.warn(
              title: "Edit Pod: ${pod.podName}",
              message: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _podController,
                    decoration: const InputDecoration(
                      hintText: "Pod Name",
                    ),
                  ),
                ],
              ),
            ),
          ).show(context);
        },
        onDelete: () {
          ConfirmFutureDialog(
            onStatusConfirmFuture: () {
              String? podId = Provider.of<JudgingPodProvider>(context, listen: false).getIdFromPodName(
                pod.podName,
              );
              if (podId == null) {
                TmsLogger().i("Pod ID is null");
                return Future.value(HttpStatus.notFound);
              } else {
                return Provider.of<JudgingPodProvider>(context, listen: false).removePod(podId);
              }
            },
            style: ConfirmDialogStyle.error(
              title: "Remove Pod: ${pod.podName}",
              message: const Text("Are you sure you want to remove this pod?"),
            ),
          ).show(context);
        },
        cells: [
          _buildCell(Text(pod.podName)),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return EchoTreeLifetime(
      trees: [
        ":judging:pods",
      ],
      child: Selector<JudgingPodProvider, List<JudgingPod>>(
        selector: (context, provider) => provider.podsByName,
        builder: (context, pods, child) {
          return Column(
            children: [
              Expanded(
                child: EditTable(
                  onAdd: () {
                    _podController.clear();
                    ConfirmFutureDialog(
                      onStatusConfirmFuture: () {
                        return Provider.of<JudgingPodProvider>(context, listen: false).insertPod(
                          null,
                          _podController.text,
                        );
                      },
                      style: ConfirmDialogStyle.warn(
                        title: "Add Pod",
                        message: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: _podController,
                              decoration: const InputDecoration(
                                hintText: "Pod Name",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).show(context);
                  },
                  headers: [
                    _buildCell(
                      const Text(
                        "Pod",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: _rows(context, pods),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
