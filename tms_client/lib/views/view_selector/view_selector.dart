import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/user.dart';
import 'package:tms/providers/auth_provider.dart';
import 'package:tms/views/view_selector/admin_views.dart';
import 'package:tms/views/view_selector/judging_views.dart';
import 'package:tms/views/view_selector/public_views.dart';
import 'package:tms/views/view_selector/robot_game_views.dart';

/**
 * Pastel colors
 * 0xff8E97FD blue/purple
 * 0xffFFC97E yellow
 * 0xffFA6E5A red
 * 0xff6CB28E green
 * 0xffD291BC violet
 * 0xff2ACAC8 cyan
 * 0xFF828282 grey
 * 0xFF2D7F9D steel blue
 */

class ViewSelector extends StatelessWidget {
  const ViewSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  // public views
                  const PublicViews(),
                  // admin views
                  if (authProvider.hasPermissionAccess(UserPermissions(admin: true))) const AdminViews(),
                  // robot game views
                  if (authProvider.hasPermissionAccess(UserPermissions(referee: true, emcee: true)))
                    const RobotGameViews(),
                  // team views
                  if (authProvider.hasPermissionAccess(UserPermissions(judge: true))) const JudgingViews(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
