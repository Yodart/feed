// ignore_for_file: avoid_setters_without_getters, invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';

import 'feed_controller.dart';
import 'feed_filter.dart';
import 'i_feed_widget.dart';

/// The underlying data orchestration of a Feed.
///
/// Feed is what powers the [FeedController] under the hood, it is responsible
/// for orchestrating the data and state inside of a feed. It is unadvisable to
/// interact directly with this class outside of a the [FeedController].
///
/// See also:
/// * [FeedController] which can control and interact with a [Feed]
class Feed<T extends Object> {
  // ignore: public_member_api_docs
  Feed(
    this.fetch, {
    List<T>? startsWith,
    this.limit = 20,
    this.sort,
    this.filter,
  }) {
    initOffset = startsWith?.length ?? 0;
    content.value = startsWith ?? [];
  }

  /// [content] The internal state of <T> type elements of a [Feed]. As a [ValueNotifier]
  /// whenever it's state is updated it will trigger the rebuild of any attached
  /// [ValueListenableBuilder] such as the ones on the Widgets that extend [IFeedWidget].
  final ValueNotifier<List<T>> content = ValueNotifier([]);

  /// [fetch] The function responsible for the query of new <T> type elements based on
  /// a given offset and limit.
  List<Future<List<T>> Function(int offset, int limit)> fetch;

  /// [initOffset] The initial offset of a feed, it is only set in case the [startsWith]
  /// param is provided. See constructor for more context.
  late final int initOffset;

  /// [offset] Hold the current state of a [Feed]'s offset, which changes every time a new
  /// query is made by the [fetch] function.
  int offset = 0;

  /// [limit] The designated limit of each query of the feed, the [fetch] functions returns
  /// (at most) this amount of <T> type elements.
  final int limit;

  /// [isExhausted] Computes if the [Feed] has queried all data available, specifically it is
  /// set to true whenever the length of the queried content is bigger then the [Feed]'s limit.
  bool isExhausted = false;

  /// [isFetching] Status of rather the [Feed] is currently fetching more data or not, this
  /// is used to prevent new queries from being triggered before others have finished.
  bool isFetching = false;

  /// [sort] The sorting function of a [Feed], basically dictates how the data (once queried
  /// should be organized). This is applied in the [_fetch] function.
  final int Function(T a, T b)? sort;

  /// [filter] The filter of the [Feed], it filters out incoming elements of a queried based
  /// on the provided filter function. See [FeedFilter] for more context.
  final FeedFilter<T>? filter;

  /// [_fetch] The private fetch function of the [Feed], it takes the provided fetch function
  /// (on the constructor), queries the data using it and then parses that data using the
  /// provided sort method if one is provided.
  Future<List<T>> _fetch() async {
    final List<List<T>> data = await Future.wait(fetch.map((e) => e(offset, limit)));
    if (data.isEmpty) return [];
    final List<T> sortedData = data.reduce((v, e) => sort != null ? [...v, ...e] : [...v, ...e]
      ..shuffle());
    if (sort != null) sortedData.sort(sort);
    return sortedData;
  }

  /// [load] Loads more content to the [content] notifier using the internal [_fetch]
  /// function if both [isFetching] and [isExhausted] are not true.
  Future<void> load({bool clear = false}) async {
    if (isFetching || isExhausted) return;
    isFetching = true;
    final List<T> newContent = await _fetch();
    if (newContent.length < limit) isExhausted = true;
    if (clear) content.value.clear();
    _appendNewContentWithFilter(newContent);
    offset += limit;
    isFetching = false;
    content.notifyListeners();
  }

  /// Refreshes the data of the feed by clearing it's elements and querying new data with
  /// the [offset] reset to 0. It also resets [isExhausted] back to `false`
  Future<void> refresh() async {
    if (isFetching) return;
    offset = 0 + initOffset;
    isExhausted = false;
    return load(clear: true);
  }

  /// Appends new incoming content from a query to the list of elements of a feed
  /// while filtering out the elements that the feed filter doesnt want.
  void _appendNewContentWithFilter(List<T> newContent) {
    if (filter == null) return content.value.addAll(newContent);
    final bool hasReachedFilterMaxReach = (content.value.length + newContent.length) >= filter!.maxReach;
    bool shouldAppendElement(T element) => !filter!.shouldFilterOut(element, content.value);
    for (final T e in newContent) if (shouldAppendElement(e) || hasReachedFilterMaxReach) content.value.add(e);
  }

  /// Exposes the items of the inner state of the feed
  List<T> get items => content.value;

  /// Computes if at its current state the feed has no content at all
  bool get hasNoContent => content.value.isEmpty && isExhausted;
}
