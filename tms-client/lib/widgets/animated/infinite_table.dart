import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tms/utils/logger.dart';

// Creates an animated infinite list which will scroll forever
// Under the hood this creates 2 duplicate lists, one after the other
// And animates the scroll to give the illusion of infinite scrolling
// Once the second list is fully visible, the scroll position is reset to the start
class AnimatedInfiniteVerticalList extends StatefulWidget {
  final List<Widget> children;
  final List<Widget> childrenSecondList;
  final double childHeight;
  final int scrollSpeed;

  const AnimatedInfiniteVerticalList({
    Key? key,
    required this.children,
    this.childrenSecondList = const [],
    required this.childHeight,
    this.scrollSpeed = 5,
  }) : super(key: key);

  @override
  State<AnimatedInfiniteVerticalList> createState() => _AniInfVertState();
}

class _AniInfVertState extends State<AnimatedInfiniteVerticalList>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  final List<GlobalKey> _keys = [];

  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;

  bool _animationInitialized = false;

  void _initInfAni() {
    if (_animationInitialized) return;

    if (widget.children.isNotEmpty) {
      _animationInitialized = true;
      _animationController = AnimationController(
        vsync: this,
        duration: Duration(seconds: (widget.children.isEmpty ? 1 : widget.children.length) * widget.scrollSpeed),
      )
        ..addListener(() {
          double resetPosition = _getChildrenTotalHeight(); // position where the second table starts
          double currentScroll = _animationController.value * resetPosition * 2; // scrolling through double the data

          if (currentScroll >= resetPosition && _scrollController.hasClients && widget.children.isNotEmpty) {
            _animationController.forward(from: 0.0);
          } else {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(currentScroll);
            }
          }
        })
        ..repeat();
    }
  }

  void _initKeys() {
    _keys.clear();
    _keys.addAll(widget.children.map((e) => GlobalKey()));
  }

  @override
  void didUpdateWidget(covariant AnimatedInfiniteVerticalList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget != oldWidget) {
      if (!listEquals(oldWidget.children, widget.children)) {
        _initKeys();
        // redo animation
        if (!_animationInitialized) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              _initInfAni();
            }
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _initInfAni();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (_animationInitialized) _animationController.dispose();
    super.dispose();
  }

  double _getChildrenTotalHeight() {
    double totalHeight = 0;
    for (int i = 0; i < widget.children.length; i++) {
      totalHeight += widget.childHeight;
    }
    return totalHeight;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        double availableHeight = constraints.maxHeight;

        if (availableHeight < _getChildrenTotalHeight()) {
          // infinite list
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (widget.childrenSecondList.isEmpty) {
                        return widget.children[index % widget.children.length];
                      } else {
                        if (index < widget.children.length) {
                          return widget.children[index];
                        } else {
                          return widget.childrenSecondList[index % widget.childrenSecondList.length];
                        }
                      }
                    },
                    childCount: widget.children.length * 2,
                  ),
                ),
              ],
            ),
          );
        } else {
          // static normal list
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return LayoutBuilder(
                        key: _keys[index],
                        builder: (context, constraints) {
                          return widget.children[index];
                        },
                      );
                    },
                    childCount: widget.children.length,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
