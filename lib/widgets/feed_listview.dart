// ignore_for_file: invalid_use_of_protected_member, avoid_positional_boolean_parameters

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../data/controller.dart';
import 'i_feed_widget.dart';

/// A feed widget that renders a regular [ListView] with its elements.
class FeedListView<T extends Object> extends IFeedWidget<T> {
  // ignore: public_member_api_docs
  const FeedListView({
    super.key,
    required final FeedController<T> controller,
    required this.itemBuilder,
    final Widget Function(BuildContext)? loadingItemBuilder,
    final ScrollPhysics? physics,
    final Axis? scrollDirection,
    final EdgeInsets? padding,
    final bool keepAlive = false,
    final bool? reverse,
    final VoidCallback? onRefresh,
    final bool refreshOnAppResumed = false,
    this.header,
    this.renderHeaderOnEmpty = true,
    this.onEmpty = const SizedBox(),
    this.bottomPadding = 200,
  }) : super(
          loadingItemBuilder: loadingItemBuilder,
          controller: controller,
          physics: physics,
          scrollDirection: scrollDirection,
          padding: padding,
          keepAlive: keepAlive,
          reverse: reverse,
          onRefresh: onRefresh,
          refreshOnAppResumed: refreshOnAppResumed,
        );

  /// Header widget rendered directly above the first item of the feed.
  final Widget? header;

  /// Widget rendered when the feed has absolutely no elements after the first query.
  final Widget onEmpty;

  /// The widget rendered for any given
  final Widget Function(BuildContext context, int index, T item) itemBuilder;

  /// The padding added to the last item being rendered so that the item can reach the
  /// center of the view and not be stuck at the bottom which on the app gets covered by
  /// the dock.
  final double bottomPadding;

  /// Determines whether to render the header even when the feed list is empty.
  final bool renderHeaderOnEmpty;

  @override
  State<FeedListView<T>> createState() => _FeedListViewState<T>();
}

class _FeedListViewState<T extends Object> extends IFeedWidgetState<FeedListView<T>, T> {
  Widget itemBuilderCallback(BuildContext context, int index) {
    final bool isItemTheLast = index == (widget.controller.feed.items.length - 1);
    final bool shouldRenderBottomPadding = isItemTheLast && widget.controller.feed.isExhausted;
    return Column(
      children: [
        if (widget.header != null && index == 0) widget.header!,
        widget.itemBuilder(context, index, widget.controller.feed.items[index]),
        if (shouldRenderBottomPadding) Container(height: widget.bottomPadding)
      ],
    );
  }

  @override
  Widget get defaultLoadingWidget => const SizedBox();

  Widget handleChildBuild({
    required bool isFeedEmpty,
    required bool isFeedQueryExhausted,
    required int feedItemsLeght,
  }) {
    if (isFeedEmpty && isFeedQueryExhausted) {
      return Column(
        children: [
          if (widget.renderHeaderOnEmpty) widget.header ?? const SizedBox(),
          Expanded(child: widget.onEmpty),
        ],
      );
    }
    Widget Function(BuildContext, int) itemBuilder = (ctx, i) => const SizedBox();
    final bool shouldRenderLoadingItem = feedItemsLeght == 0;
    if (shouldRenderLoadingItem) {
      itemBuilder = (ctx, i) {
        return Column(
          children: [
            if (widget.header != null && i == 0) widget.header!,
            loadingItemBuilder(ctx, i),
          ],
        );
      };
    }
    if (feedItemsLeght != 0) itemBuilder = itemBuilderCallback;
    final int targetItemCount = feedItemsLeght > 0 ? feedItemsLeght : 50;

    return ListView.builder(
      controller: widget.controller.scrollController,
      physics: widget.physics ?? const BouncingScrollPhysics(),
      padding: feedPadding,
      itemCount: targetItemCount,
      itemBuilder: itemBuilder,
      addRepaintBoundaries: false,
      addAutomaticKeepAlives: widget.keepAlive,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ValueListenableBuilder<List<T>>(
      valueListenable: widget.controller.feed.content,
      builder: (context, value, _) {
        final Widget child = handleChildBuild(
            feedItemsLeght: value.length,
            isFeedEmpty: widget.controller.feed.items.isEmpty,
            isFeedQueryExhausted: widget.controller.feed.isExhausted);

        return SmartRefresher(
          enablePullDown: true,
          physics: widget.physics ?? const BouncingScrollPhysics(),
          enablePullUp: !widget.controller.feed.isExhausted,
          controller: refreshController,
          reverse: widget.reverse,
          scrollDirection: widget.scrollDirection,
          onRefresh: onRefreshCallback,
          onLoading: onLoadingCallback,
          header: CustomHeader(builder: (_, status) => const SizedBox()),
          footer: CustomFooter(builder: (_, status) => const SizedBox()),
          child: child,
        );
      },
    );
  }
}
