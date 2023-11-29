// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'package:flutter/material.dart';

import '../feed.dart';

/// The controller of a feed. It interacts with the feed itself and the scroll controller
/// used inside of feed widgets.
class FeedController<T extends Object> {
  // ignore: public_member_api_docs
  FeedController({required this.fetch, this.limit, this.startsWith, this.sort, this.filter}) {
    _init();
  }

  @protected

  /// The actual feed contained inside of a feed controller.
  late final Feed<T> feed;

  /// List of fetch functions responsible for querying new data into the feed.
  final List<Future<List<T>> Function(int offset, int limit)> fetch;

  /// The filter of feed. See [FeedFilter] for more context.
  final FeedFilter<T>? filter;

  /// The max ammount of elements queried on any given request. Defaults to 20.
  final int? limit;

  /// The scroll controller used inside of the feed widgets.
  ScrollController? scrollController;

  /// The list of elements that the feed should start with.
  final List<T>? startsWith;

  /// Lays out how incoming data should be sorted or not.
  final int Function(T a, T b)? sort;

  /// Whether the [FeedController] is initiliaed or not
  bool initialized = false;

  void _init() {
    if (initialized) return;
    scrollController = ScrollController();
    feed = Feed(fetch, limit: limit ?? 20, startsWith: startsWith, sort: sort, filter: filter);
    initialized = true;
  }

  /// Refreshes the feed
  Future<void> refresh() async => feed.refresh();

  /// Loads more
  Future<void> load() async => feed.load();

  bool get _isScrollControllerInteractable => scrollController?.hasClients ?? false;

  /// Whether the current scroll position is [position.minScrollExtent]
  bool get isAtMinScroll {
    if (!_isScrollControllerInteractable) return false;
    return scrollController!.position.pixels == scrollController!.position.minScrollExtent;
  }

  /// Resets the scroll position to the minimum possible position.
  /// If the feed is already in its minimum position, the [ifAtMinScroll] callback will be executed.
  /// This function is commonly used in application navigation buttons.
  Future<void> resetScroll({Function()? ifAtMinScroll}) async {
    if (!_isScrollControllerInteractable) return;
    if (isAtMinScroll) return ifAtMinScroll?.call();
    scrollController!.animateTo(scrollController!.position.minScrollExtent,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOutCubic);
  }

  /// Appends a new item into the content of the feed @ it's current state.
  void addItem(T item) {
    feed.content.value.add(item);
    feed.content.notifyListeners();
  }

  /// Removes an item from the content of the feed @ it's current state.
  void removeItem(T item) {
    feed.content.value.remove(item);
    feed.content.notifyListeners();
  }

  /// Removes all objects from this feed that satisfy [test].
  void removeWhere(bool Function(T) test) {
    feed.content.value.removeWhere(test);
    feed.content.notifyListeners();
  }

  /// Insert an item into the content of the feed @ it's current state in a given index.
  void insertItem(int index, T item) {
    feed.content.value.insert(index, item);
    feed.content.notifyListeners();
  }

  /// Updates an item in the content of the feed @ it's current state.
  void updateItem(int index, T item) {
    feed.content.value[index] = item;
    feed.content.notifyListeners();
  }

  /// Insert an item into the content of the feed @ if that element is not already there.
  void insertIfAbsent(int index, T item) {
    if (feed.content.value.contains(item)) return;
    insertItem(index, item);
  }

  /// Checks if the provided object of type T is contained within the current state of feed items.
  bool contains(T item) => feed.content.value.contains(item);

  /// Returns the index of the provided object. If not present on the list it will return -1.
  int indexOf(T item) => feed.content.value.indexOf(item);

  /// Returns the index of the first index in the list that satisfies the provided [test].
  int indexWhere(bool Function(T) test) => feed.content.value.indexWhere(test);

  T elementAt(int index) => feed.content.value.elementAt(index);

  /// Updates the fetch function of the feed, which will dictate how new queries will be made
  // ignore: avoid_setters_without_getters
  set updateFetch(List<Future<List<T>> Function(int offset, int limit)> fetch) => feed.fetch = fetch;

  /// Disposes the inner content notifier and the scroll controller (if available)
  void dispose() {
    feed.content.value = [];
    feed.content.dispose();
    scrollController?.dispose();
  }
}

/// A [FeedController] that has no [ScrollController], this is used almost exclusively on
/// content views inside the app given that no scroll controllers must exist there.
class FeedControllerWithoutScrollController<T extends Object> extends FeedController<T> {
  // ignore: public_member_api_docs
  FeedControllerWithoutScrollController({
    required final List<Future<List<T>> Function(int offset, int limit)> fetch,
    final int? limit,
    final List<T>? startsWith,
    final int Function(T a, T b)? sort,
    final FeedFilter<T>? filter,
  }) : super(fetch: fetch, limit: limit, startsWith: startsWith, sort: sort, filter: filter);

  @override
  void _init() {
    if (initialized) return;
    feed = Feed(fetch, limit: limit ?? 20, startsWith: startsWith, sort: sort, filter: filter);
    initialized = true;
  }
}
