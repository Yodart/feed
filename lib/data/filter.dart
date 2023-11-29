/// The optional filter of a feed, its responsible for laying out how a
/// given new incoming element will be treated (insert or not).
class FeedFilter<T extends Object> {
  // ignore: public_member_api_docs
  FeedFilter(this.shouldFilterOut, {this.maxReach = 100});

  /// Default filter for removing duplicates from a feed.
  factory FeedFilter.noDuplicates({int maxReach = 100}) {
    return FeedFilter((element, currentContent) => currentContent.contains(element), maxReach: maxReach);
  }

  /// Callback funciton that defines if a given incoming element should be filtered
  /// out of the feed when compered to the current list of elements
  final bool Function(T element, List<T> currentContent) shouldFilterOut;

  /// The max reach of the feed, if a new incoming element has index bigger then this
  /// it will never be filtered out. This is done due to perofrmance constraints an it
  /// defaults to 100.
  final int maxReach;
}
