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

  @override
  State<FeedListView<T>> createState() => _FeedListViewState<T>();
}

class _FeedListViewState<T extends Object> extends IFeedWidgetState<FeedListView<T>, T> {
  @override
  Widget get defaultLoadingWidget => const SizedBox();

  List<Widget> _itemsBuilder(BuildContext context, bool isFeedLoading, int index) {
    if (isFeedLoading) {
      return [loadingItemBuilder(context, index)];
    }
    final bool isItemTheLast = index == (widget.controller.feed.items.length - 1);
    final bool shouldRenderBottomPadding = isItemTheLast && widget.controller.feed.isExhausted;
    return [
      widget.itemBuilder(context, index, widget.controller.feed.items[index]),
      if (shouldRenderBottomPadding) Container(height: widget.bottomPadding)
    ];
  }

  Widget _handleChildBuild({
    required bool isFeedEmpty,
    required bool isFeedQueryExhausted,
    required int feedItemsLength,
  }) {
    if (isFeedEmpty && isFeedQueryExhausted) {
      return ListView(
        children: [
          Column(
            children: [
              if (widget.header != null) widget.header!,
              widget.onEmpty,
            ],
          )
        ],
      );
    }
    final bool isFeedLoading = feedItemsLength == 0;
    final int targetItemCount = feedItemsLength > 0 ? feedItemsLength : 50;

    return ListView.builder(
      controller: widget.controller.scrollController,
      physics: widget.physics ?? const BouncingScrollPhysics(),
      padding: feedPadding,
      itemCount: targetItemCount,
      itemBuilder: (context, index) => Column(
        children: [
          if (widget.header != null && index == 0) widget.header!,
          ..._itemsBuilder(context, isFeedLoading, index),
        ],
      ),
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
        final Widget child = _handleChildBuild(
          feedItemsLength: value.length,
          isFeedEmpty: widget.controller.feed.items.isEmpty,
          isFeedQueryExhausted: widget.controller.feed.isExhausted,
        );

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
