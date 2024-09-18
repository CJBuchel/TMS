import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Creates an animated infinite list which will scroll forever
// Under the hood this creates 2 duplicate lists, one after the other
// And animates the scroll to give the illusion of infinite scrolling
// Once the second list is fully visible, the scroll position is reset to the start
class AnimatedInfiniteVerticalList extends StatefulWidget {
  final List<Widget> children;
  final double childHeight;
  final int scrollSpeed;
  final bool duplicateWhenChildrenOdd;

  const AnimatedInfiniteVerticalList({
    Key? key,
    required this.children,
    required this.childHeight,
    this.scrollSpeed = 5,
    this.duplicateWhenChildrenOdd = true,
  }) : super(key: key);

  @override
  State<AnimatedInfiniteVerticalList> createState() => _AniInfVertState();
}

class _AniInfVertState extends State<AnimatedInfiniteVerticalList>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;

  bool _animationInitialized = false;

  List<Widget> _getChildren() {
    if (widget.duplicateWhenChildrenOdd && widget.children.length % 2 != 0) {
      return List.from(widget.children)..addAll(widget.children);
    } else {
      return widget.children;
    }
  }

  double _getChildrenTotalHeight({bool actual = false}) {
    if (actual) {
      return widget.children.length * widget.childHeight;
    } else {
      return _getChildren().length * widget.childHeight;
    }
  }

  void _initInfAni() {
    if (_animationInitialized) return;

    if (_getChildren().isNotEmpty) {
      _animationInitialized = true;
      _animationController = AnimationController(
        vsync: this,
        duration: Duration(seconds: (_getChildren().isEmpty ? 1 : _getChildren().length) * widget.scrollSpeed),
      )
        ..addListener(() {
          double resetPosition = _getChildrenTotalHeight(); // position where the second table starts
          double currentScroll = _animationController.value * resetPosition * 2; // scrolling through double the data

          if (currentScroll >= resetPosition && _scrollController.hasClients && _getChildren().isNotEmpty) {
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

  @override
  void didUpdateWidget(covariant AnimatedInfiniteVerticalList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget != oldWidget) {
      if (!listEquals(oldWidget.children, widget.children)) {
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        double availableHeight = constraints.maxHeight;

        if (availableHeight < _getChildrenTotalHeight(actual: true)) {
          // infinite list
          return RepaintBoundary(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return RepaintBoundary(
                          child: _getChildren()[index % _getChildren().length],
                        );
                      },
                      childCount: _getChildren().length * 2,
                    ),
                  ),
                ],
              ),
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
                        builder: (context, constraints) {
                          return RepaintBoundary(
                            child: widget.children[index],
                          );
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
