import 'package:flutter/material.dart';
import 'package:tms_client/views/home/grid_card.dart';

class GridList extends StatelessWidget {
  final List<GridCard> cards;

  const GridList({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.5,
        mainAxisExtent: 220,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => cards[index],
        childCount: cards.length,
      ),
    );
  }
}
