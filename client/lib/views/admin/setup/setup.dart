import 'package:flutter/material.dart';
import 'package:tms/responsive.dart';
import 'package:tms/views/admin/setup/api_setup.dart';
import 'package:tms/views/admin/setup/offline_setup.dart';
import 'package:tms/views/shared/tool_bar.dart';

class Setup extends StatelessWidget {
  const Setup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TmsToolBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (Responsive.isMobile(context)) {
            return const SingleChildScrollView(
              child: Column(
                children: [
                  OfflineSetup(),
                  APISetup(),
                ],
              ),
            );
          } else {
            // scrollable row
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: constraints.maxWidth / 2,
                  height: constraints.maxHeight,
                  child: const SingleChildScrollView(
                    child: OfflineSetup(),
                  ),
                ),
                SizedBox(
                  width: constraints.maxWidth / 2,
                  height: constraints.maxHeight,
                  child: const APISetup(),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
