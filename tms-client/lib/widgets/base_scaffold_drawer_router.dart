import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:tms/widgets/app_bar/app_bar.dart';
import 'package:tms/widgets/base_responsive.dart';

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
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: const Center(child: Icon(Icons.keyboard_arrow_right)),
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
  final String goRoute;

  const BaseScaffoldDrawerRouterItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.goRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: title,
      onTap: () {
        context.go(goRoute);
      },
    );
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
    return BaseResponsive(
      child: Scaffold(
        appBar: TmsAppBar(state: state),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                child: Image.asset('assets/logos/TMS_LOGO_NO_TEXT.png'),
              ),
              ...(items ?? []),
            ],
          ),
        ),

        // child with stack
        body: _DrawStack(
          child: child,
        ),
      ),
    );
  }
}
