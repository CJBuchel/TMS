import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TmsAppBarLeading extends StatelessWidget {
  final GoRouterState state;

  const TmsAppBarLeading({
    Key? key,
    required this.state,
  }) : super(key: key);

  Widget _showHome(BuildContext context) {
    if (state.matchedLocation == '/') {
      return const SizedBox();
    } else {
      return IconButton(
        icon: const Icon(Icons.home),
        onPressed: () {
          context.go('/');
        },
      );
    }
  }

  // Widget _showBack(BuildContext context) {
  //   if (context.canPop()) {
  //     return IconButton(
  //       icon: const Icon(Icons.arrow_back),
  //       onPressed: () {
  //         context.pop();
  //       },
  //     );
  //   } else {
  //     return const SizedBox();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _showHome(context),
        // _showBack(context),
      ],
    );
  }
}
