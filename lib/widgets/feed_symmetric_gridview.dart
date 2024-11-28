// ignore_for_file: invalid_use_of_protected_member, avoid_positional_boolean_parameters
import 'package:feed/data/controller.dart';
import 'package:feed/widgets/i_feed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// A feed widget that renders a symmetric grid where all items items have the same
/// space to render themselves.
class FeedSymmetricGridView<T extends Object> extends IFeedWidget<T> {
  // ignore: public_member_api_docs
  const FeedSymmetricGridView({
    super.key,
    required final FeedController<T> controller,
    required this.itemBuilder,
    final Widget Function(BuildContext)? loadingItemBuilder,
    final ScrollPhysics? physics,
    final Axis? scrollDirection,
    final EdgeInsets? padding,
    final bool keepAlive = false,
    final bool? reverse,
    this.staggeredTileBuilder,
    this.crossAxisCount,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.shrinkwrap,
    this.onEmpty = const SizedBox(),
    this.headerSliverBuilder,
    this.refreshOnInit = true,
    this.shouldLoadOnInit = false,
  }) : super(
          loadingItemBuilder: loadingItemBuilder,
          controller: controller,
          physics: physics,
          scrollDirection: scrollDirection,
          padding: padding,
          keepAlive: keepAlive,
          reverse: reverse,
        );

  /// The callback function responsible for rendering a grid item for a given feed element.
  final Widget Function(BuildContext context, int index, T item) itemBuilder;

  /// Widget rendered when the feed has absolutely no elements after the first query.
  final Widget onEmpty;

  /// The ammount of items contained in reach row of the feed, defaults to 3.
  final int? crossAxisCount;

  /// The space between the rows of grid objects
  final double? mainAxisSpacing;

  /// The space between the grid objects inside of a row
  final double? crossAxisSpacing;

  /// Lays out how each row should be rendered
  final StaggeredTile? Function(int)? staggeredTileBuilder;

  /// If shrinkwrap should be applied to the scrollable widget.
  final bool? shrinkwrap;

  /// If the feed should refresh when this widget is first rendered
  final bool refreshOnInit;

  /// If the feed should load its content on init. Not to be confused with
  /// [refreshOnInit] this param exists to prevent that a feed that a feed that
  /// has already been initialized loads more unecessary content.
  final bool shouldLoadOnInit;

  /// Sliver hender at the top of the NestedScroll controller contained inside of the widget
  /// The header for this widget is implement differently then the one on [FeedInViewListView]
  /// to avoid conflicts with the [NestedScrollView] rendered on content view (Profile, GGPs)
  final List<Widget> Function(BuildContext context, bool innerBoxIsScrolled)? headerSliverBuilder;

  /// The [FeedGridViewOverlayController] for the grid widget.

  @override
  State<FeedSymmetricGridView<T>> createState() => _FeedSymmetricGridViewState<T>();
}

class _FeedSymmetricGridViewState<T extends Object> extends IFeedWidgetState<FeedSymmetricGridView<T>, T> {
  @override
  Widget get defaultLoadingWidget => const SizedBox();

  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  bool get refreshOnInit => widget.refreshOnInit;

  Widget handleChildBuild({
    required bool isFeedEmpty,
    required bool isFeedQueryExhausted,
    required int feedItemsLeght,
  }) {
    if (isFeedEmpty && isFeedQueryExhausted) return widget.onEmpty;
    Widget Function(BuildContext, int) itemBuilder = (ctx, i) => const SizedBox();
    if (feedItemsLeght == 0) {
      itemBuilder = loadingItemBuilder;
    } else {
      itemBuilder = (ctx, i) => widget.itemBuilder(context, i, widget.controller.feed.items[i]);
    }
    final int targetItemCount = feedItemsLeght > 0 ? feedItemsLeght : 50;
    return StaggeredGridView.countBuilder(
      padding: feedPadding,
      crossAxisCount: widget.crossAxisCount ?? 3,
      itemCount: targetItemCount,
      itemBuilder: itemBuilder,
      staggeredTileBuilder: widget.staggeredTileBuilder ?? (_) => const StaggeredTile.count(1, 1),
      mainAxisSpacing: widget.mainAxisSpacing ?? 8,
      crossAxisSpacing: widget.crossAxisSpacing ?? 8,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
      controller: widget.headerSliverBuilder == null ? widget.controller.scrollController : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ValueListenableBuilder<List<T>>(
        valueListenable: widget.controller.feed.content,
        builder: (context, value, _) {
          final Widget childBuild = handleChildBuild(
            feedItemsLeght: value.length,
            isFeedEmpty: widget.controller.feed.items.isEmpty,
            isFeedQueryExhausted: widget.controller.feed.isExhausted,
          );
          return SmartRefresher(
            enablePullDown: true,
            enablePullUp: !widget.controller.feed.isExhausted,
            controller: refreshController,
            physics: widget.physics,
            reverse: widget.reverse,
            scrollDirection: widget.scrollDirection,
            onRefresh: onRefreshCallback,
            onLoading: onLoadingCallback,
            header: CustomHeader(builder: (_, status) => const SizedBox()),
            footer: CustomFooter(builder: (_, status) => const SizedBox()),
            child: childBuild,
          );
        });
  }
}
