// ignore_for_file: prefer_mixin

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../data/controller.dart';

/// The abstraction of a widget that renders and interacts with a Feed and it's controller.
abstract class IFeedWidget<T extends Object> extends StatefulWidget {
  // ignore: public_member_api_docs
  const IFeedWidget({
    super.key,
    required this.keepAlive,
    required this.controller,
    this.padding,
    this.loadingItemBuilder,
    this.scrollDirection,
    this.physics,
    this.reverse,
    this.onRefresh,
    this.refreshOnAppResumed = false,
  });

  /// The widget rendered when the feed is doing its first query.
  final Widget Function(BuildContext)? loadingItemBuilder;

  /// The required [FeedController] of a feed widget, responsible for interacting with
  /// the feed itself contained inside of it.
  final FeedController<T> controller;

  /// The physics inside of the scrollable widget rendered by the FeedWidget
  final ScrollPhysics? physics;

  /// The axis in which the scroll is done. Defaults to be vertical
  final Axis? scrollDirection;

  /// The padding of the feed added around it's items.
  final EdgeInsets? padding;

  /// If the state of the feed it self should be kept alive. Set to true in cases where
  /// the feed should be loosing state like Explore or a Profile.
  final bool keepAlive;

  /// If the scrolling should reversed or not.
  final bool? reverse;

  /// Callback function called when the user overscrolls the list of items
  final VoidCallback? onRefresh;

  /// If the feed should be refresh when to user goes out of the app and comes back
  final bool refreshOnAppResumed;

  @override
  // ignore: no_logic_in_create_state
  State<IFeedWidget> createState() => throw UnimplementedError();
}

/// Implementation for the FeedWidget state
abstract class IFeedWidgetState<T extends IFeedWidget<K>, K extends Object> extends State<T>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  ///  Controller responsible for refreshing the Feed Widget
  final RefreshController refreshController = RefreshController();

  /// Controller for the Feed Widget
  late final FeedController<K> controller;

  @override
  bool get wantKeepAlive => widget.keepAlive;

  /// Whether or not the feed should refresh on [initState]
  bool get refreshOnInit => true;

  /// Padding for the [IFeedWidget] and any widget that inherits it
  EdgeInsets get feedPadding => widget.padding ?? EdgeInsets.zero;

  @mustCallSuper
  @override
  void initState() {
    super.initState();
    if (widget.refreshOnAppResumed) WidgetsBinding.instance.addObserver(this);
    controller = widget.controller;
    if (refreshOnInit) controller.refresh();
  }

  @mustCallSuper
  @override
  void dispose() {
    if (widget.refreshOnAppResumed) WidgetsBinding.instance.removeObserver(this);
    refreshController.dispose();
    super.dispose();
  }

  /// Default loading widget
  Widget get defaultLoadingWidget => const SizedBox();

  /// Builder for the loading widget
  Widget loadingItemBuilder(BuildContext ctx, int i) =>
      widget.loadingItemBuilder != null ? widget.loadingItemBuilder!(ctx) : defaultLoadingWidget;

  /// Callback for when the feed is being refreshed
  @mustCallSuper
  Future<void> onRefreshCallback() async {
    await controller.refresh();
    refreshController.refreshCompleted();
    if (widget.onRefresh != null) widget.onRefresh!();
  }

  /// Callback for when the feed is loading
  @mustCallSuper
  void onLoadingCallback() {
    controller.load();
    refreshController.loadComplete();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state != AppLifecycleState.resumed || !widget.refreshOnAppResumed) return;
    if (widget.controller.initialized) await widget.controller.refresh();
    if (widget.controller.scrollController != null && widget.controller.scrollController!.hasClients) {
      await widget.controller.resetScroll();
    }
  }
}
