// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';

import '../feed_controller.dart';
import '../i_feed_widget.dart';

/// A feed widget that renders a [PageView] with a page for each of its elements.
class FeedPageView<T extends Object> extends IFeedWidget<T> {
  const FeedPageView({
    super.key,
    required final FeedController<T> controller,
    required this.itemBuilder,
    final Widget Function(BuildContext)? loadingItemBuilder,
    final ScrollPhysics? physics,
    final Axis? scrollDirection,
    final EdgeInsets? padding = EdgeInsets.zero,
    final bool keepAlive = false,
    final bool? reverse,
    final bool refreshOnAppResumed = false,
    this.initialPage,
    this.pageController,
    this.refreshOnInit = false,
    this.shouldLoadOnInit = false,
    this.onPageChanged,
    this.onEmpty,
  }) : super(
          loadingItemBuilder: loadingItemBuilder,
          controller: controller,
          physics: physics,
          scrollDirection: scrollDirection,
          padding: padding,
          keepAlive: keepAlive,
          reverse: reverse,
          refreshOnAppResumed: refreshOnAppResumed,
        );

  /// Callback function that renders the view for a given element on the feed
  final Widget Function(BuildContext context, int index, T item) itemBuilder;

  /// Widget rendered when the feed is empty
  final Widget Function(BuildContext context)? onEmpty;

  /// Callback trigger when the current page of the PageView changes.
  final Function(int)? onPageChanged;

  /// The initial page to be redenred, defaults to be the first one.
  final int? initialPage;

  /// The page controller attach to the [PageView] widget
  final PageController? pageController;

  /// If the feed should refresh when this widget is first rendered
  final bool refreshOnInit;

  /// If the feed should load its content on init. Not to be confused with
  /// [refreshOnInit] this param exists to prevent that a feed that a feed that
  /// has already been initialized loads more unecessary content.
  final bool shouldLoadOnInit;

  @override
  State<FeedPageView<T>> createState() => _FeedPageViewState<T>();
}

class _FeedPageViewState<T extends Object> extends IFeedWidgetState<FeedPageView<T>, T> {
  @override
  bool get refreshOnInit => widget.refreshOnInit;

  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  void initState() {
    super.initState();
    if (widget.shouldLoadOnInit) widget.controller.load();
  }

  Widget onEmpty() {
    Widget Function(BuildContext) builder = (_) => Container(color: Colors.red);
    if (widget.onEmpty != null) builder = widget.onEmpty!;
    return builder(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ValueListenableBuilder<List<T>>(
        valueListenable: widget.controller.feed.content,
        builder: (context, value, _) {
          if (widget.controller.feed.hasNoContent) return onEmpty();
          Widget itemBuilderCallback(BuildContext context, int index) {
            if (index + 2 > widget.controller.feed.items.length) widget.controller.load();
            return widget.itemBuilder(context, index, widget.controller.feed.items[index]);
          }

          return PageView.builder(
            onPageChanged: widget.onPageChanged,
            allowImplicitScrolling: true,
            padEnds: false,
            itemCount: value.length,
            itemBuilder: itemBuilderCallback,
            physics: widget.physics,
            reverse: widget.reverse ?? false,
            scrollDirection: widget.scrollDirection ?? Axis.vertical,
            controller: widget.pageController ?? PageController(initialPage: widget.initialPage ?? 0),
          );
        });
  }
}
