import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:tms/generated/infra/database_schemas/user.dart';
import 'package:tms/providers/auth_provider.dart';
import 'package:tms/widgets/app_bar/app_bar.dart';

class _DrawStack extends StatelessWidget {
  final Widget child;

  const _DrawStack({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double buttonWidth = ResponsiveBreakpoints.of(context).isMobile ? 20 : 30;
    return Stack(
      children: [
        // inserted child
        child,

        // drawer open button
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: Container(
              width: buttonWidth,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: const Border(
                  top: BorderSide(
                    color: Colors.black,
                    width: 1,
                  ),
                  bottom: BorderSide(
                    color: Colors.black,
                    width: 1,
                  ),
                  right: BorderSide(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: const Center(child: Icon(Icons.chevron_right)),
            ),
          ),
        )
      ],
    );
  }
}

class BaseScaffoldDrawerRouterItem extends StatelessWidget {
  final IconData icon;
  final Widget title;
  final String goNamed;
  final UserPermissions? permissions;

  const BaseScaffoldDrawerRouterItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.goNamed,
    this.permissions,
  }) : super(key: key);

  Widget _tile(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: title,
      onTap: () {
        context.goNamed(goNamed);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (permissions != null) {
      if (Provider.of<AuthProvider>(context, listen: false).hasPermissionAccess(permissions!)) {
        return _tile(context);
      } else {
        return const SizedBox();
      }
    } else {
      return _tile(context);
    }
  }
}

class BaseScaffoldDrawerRouter extends StatelessWidget {
  final GoRouterState state;
  final Widget child;
  final List<BaseScaffoldDrawerRouterItem>? items;

  const BaseScaffoldDrawerRouter({
    Key? key,
    required this.state,
    required this.child,
    this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TmsAppBar(state: state),
      drawer: Drawer(
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  DrawerHeader(
                    child: Image.asset('assets/logos/TMS_LOGO_NO_TEXT.png'),
                  ),
                  ...(items ??
                      [
                        const Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: const Text('Admin Tools', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ),
                        const BaseScaffoldDrawerRouterItem(
                          icon: Icons.dashboard,
                          title: const Text('Dashboard'),
                          goNamed: 'dashboard',
                        ),
                        const BaseScaffoldDrawerRouterItem(
                          icon: Icons.person,
                          title: const Text('Users'),
                          goNamed: 'users',
                        ),
                        const BaseScaffoldDrawerRouterItem(
                          icon: Icons.backup,
                          title: const Text('Backups'),
                          goNamed: 'backups',
                        ),
                        const BaseScaffoldDrawerRouterItem(
                          icon: Icons.settings,
                          title: const Text('Setup'),
                          goNamed: 'setup',
                        ),
                        const Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: const Text('Teams', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ),
                        BaseScaffoldDrawerRouterItem(
                          icon: Icons.people,
                          title: const Text('Teams'),
                          goNamed: 'teams',
                          permissions: UserPermissions(judgeAdvisor: true),
                        ),
                        const BaseScaffoldDrawerRouterItem(
                          icon: Icons.table_view,
                          title: const Text('Team Data'),
                          goNamed: 'team_data',
                        ),
                        const Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: const Text('Robot Games', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ),
                        const BaseScaffoldDrawerRouterItem(
                          icon: Icons.edit_document,
                          title: const Text('Referee Scoring'),
                          goNamed: 'scoring',
                        ),
                        const BaseScaffoldDrawerRouterItem(
                          icon: Icons.shuffle,
                          title: const Text('Match Controller'),
                          goNamed: 'match_controller',
                        ),
                        const BaseScaffoldDrawerRouterItem(
                          icon: Icons.table_chart,
                          title: const Text('Matches'),
                          goNamed: 'game_matches',
                        ),
                        const BaseScaffoldDrawerRouterItem(
                          icon: Icons.table_restaurant,
                          title: const Text('Tables'),
                          goNamed: 'game_tables',
                        ),
                        const Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: const Text('Judging', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ),
                        const BaseScaffoldDrawerRouterItem(
                          icon: Icons.table_chart,
                          title: const Text('Judging Sessions'),
                          goNamed: 'judging_sessions',
                        ),
                        const BaseScaffoldDrawerRouterItem(
                          icon: Icons.table_bar,
                          title: const Text('Pods'),
                          goNamed: 'judging_pods',
                        ),
                      ]),
                ],
              ),
            ),
          ],
        ),
      ),

      // child with stack
      body: _DrawStack(
        child: child,
      ),
    );
  }
}
