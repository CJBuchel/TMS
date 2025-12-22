import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tms_client/generated/common/common.pbenum.dart';
import 'package:tms_client/providers/auth_provider.dart';
import 'package:tms_client/utils/permissions.dart';
import 'package:tms_client/views/home/admin_cards.dart';
import 'package:tms_client/views/home/public_cards.dart';
import 'package:tms_client/views/home/referee_cards.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  Widget _paddedSliver(Widget sliver) {
    return SliverPadding(padding: const EdgeInsets.all(16.0), sliver: sliver);
  }

  Widget _bannerWidget(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 40, left: 10, right: 10),
        child: Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 28, color: Colors.blueGrey[800]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(rolesProvider);

    List<Widget> protectedCard(String title, Widget card, List<Role> required) {
      if (required.any((req) => roles.any((r) => r.hasPermission(req)))) {
        return [_bannerWidget(title), _paddedSliver(card)];
      } else {
        return [];
      }
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Public cards
        _bannerWidget('Public Views'),
        _paddedSliver(const PublicCards()),
        ...protectedCard('Admin Views', AdminCards(), [Role.ADMIN]),
        ...protectedCard('Referee Views', RefereeCards(roles: roles), [
          Role.REFEREE,
        ]),
      ],
    );
  }
}
