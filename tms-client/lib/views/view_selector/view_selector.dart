import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/auth_provider.dart';
import 'package:tms/utils/permissions.dart';
import 'package:tms/views/view_selector/admin_views.dart';
import 'package:tms/views/view_selector/public_views.dart';
import 'package:tms/views/view_selector/referee_views.dart';

/**
 * Pastel colors
 * 0xff8E97FD blue/purple
 * 0xffFFC97E yellow
 * 0xffFA6E5A red
 * 0xff6CB28E green
 * 0xffD291BC violet
 * 0xff2ACAC8 cyan
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
                  if (authProvider.hasAccess(const Permissions(admin: true))) const AdminViews(),
                  // referee screens
                  if (authProvider.hasAccess(const Permissions(referee: true))) const RefereeViews(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
