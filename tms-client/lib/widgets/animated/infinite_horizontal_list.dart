import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AnimatedInfiniteHorizontalList extends StatefulWidget {
  final List<Widget> children;
  final double childWidth;
  final int scrollSpeed;

  const AnimatedInfiniteHorizontalList({
    Key? key,
    required this.children,
    required this.childWidth,
    this.scrollSpeed = 5,
  }) : super(key: key);

  @override
  State<AnimatedInfiniteHorizontalList> createState() => _AniInfHorState();
}

class _AniInfHorState extends State<AnimatedInfiniteHorizontalList>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;

  bool _animationInitialized = false;

  double _getChildrenTotalWidth() {
    double totalWidth = 0;
    for (int i = 0; i < widget.children.length; i++) {
      totalWidth += widget.childWidth;
    }
    return totalWidth;
  }

  void _initInfAni() {
    if (_animationInitialized) return;

    if (widget.children.isNotEmpty) {
      _animationInitialized = true;
      _animationController = AnimationController(
        vsync: this,
        duration: Duration(seconds: (widget.children.isEmpty ? 1 : widget.children.length) * widget.scrollSpeed),
      )
        ..addListener(() {
          double resetPosition = _getChildrenTotalWidth(); // position where the second table starts
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

  @override
  void didUpdateWidget(covariant AnimatedInfiniteHorizontalList oldWidget) {
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
        double availableWidth = constraints.maxWidth;

        if (availableWidth < _getChildrenTotalWidth()) {
          // infinite list
          return RepaintBoundary(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: CustomScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return RepaintBoundary(
                          child: widget.children[index % widget.children.length],
                        );
                      },
                      childCount: widget.children.length * 2,
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
              scrollDirection: Axis.horizontal,
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
