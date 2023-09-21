import 'package:flutter/material.dart';
import 'package:ui_library/ui_library.dart';

import '../../feed.dart';

/// Defines the type of asymmetry for the `FeedAsymmetricGridView` widget.
enum GridAsymmetryType {
  /// Used on explore feeds using its deigned styling.
  explore,

  /// Used on ranking feeds using its deigned styling.
  ranking,
}

/// A feed widget that renders a asymmetric grid where each one of it items follow a
/// different rendering logic. Mostly used on Explore and Library grids.
///
/// [itemBuilder] must be treated with a special level of attention. This grid view
/// rendered differently depending on what [type] param is provided which means that
/// the available constraits for GridObjects from the build of the [itemBuilder] will
/// be different. We must make sure that the grid objects return on this build method
/// match the appropriate grid asymeetry.
class FeedAsymmetricGridView<T extends Object> extends FeedSymmetricGridView<T> {
  // ignore: public_member_api_docs
  FeedAsymmetricGridView({
    required final Widget Function(BuildContext context, int index, T item) itemBuilder,
    required final FeedController<T> controller,
    final GridAsymmetryType type = GridAsymmetryType.explore,
    final Widget onEmpty = const SizedBox(),
    final Widget Function(BuildContext)? loadingItemBuilder,
    final ScrollPhysics? physics,
    final double? mainAxisSpacing,
    final double? crossAxisSpacing,
    final bool? shrinkwrap,
    final bool? reverse,
    final Axis? scrollDirection,
    final EdgeInsets? padding,
    final bool keepAlive = false,
    final FeedGridViewOverlayController? overlayController,
    final Duration? refreshOnAppResumedAfterDuration,
    final List<Widget> Function(BuildContext, bool)? headerSliverBuilder,
  }) : super(
          itemBuilder: itemBuilder,
          keepAlive: keepAlive,
          physics: physics,
          onEmpty: onEmpty,
          crossAxisCount: _computeCrossAxisCount(type),
          mainAxisSpacing: mainAxisSpacing ?? _computeMainAxisSpacing(type),
          crossAxisSpacing: crossAxisSpacing ?? _computeCrossAxisSpacing(type),
          shrinkwrap: shrinkwrap,
          controller: controller,
          reverse: reverse,
          loadingItemBuilder: loadingItemBuilder,
          scrollDirection: scrollDirection,
          staggeredTileBuilder: (i) => _buildStaggeredTile(type, i),
          padding: padding,
          overlayController: overlayController,
          refreshOnAppResumedAfterDuration: refreshOnAppResumedAfterDuration,
          headerSliverBuilder: headerSliverBuilder,
        );

  static double _computeMainAxisSpacing(GridAsymmetryType type) {
    if (type == GridAsymmetryType.explore) return UIScale.width(2);
    return UIScale.width(1.6);
  }

  static double _computeCrossAxisSpacing(GridAsymmetryType type) {
    if (type == GridAsymmetryType.explore) return UIScale.width(2);
    return UIScale.width(1.6);
  }

  static int _computeCrossAxisCount(GridAsymmetryType type) {
    if (type == GridAsymmetryType.explore) return 3;
    return 2;
  }

  static StaggeredTile _buildStaggeredTile(GridAsymmetryType type, int i) {
    int crossAxisCellCount = 1;
    double mainAxisCellCount = 1;

    void setCellCount(int cross, double main) {
      crossAxisCellCount = cross;
      mainAxisCellCount = main;
    }

    if (type == GridAsymmetryType.explore) {
      final bool isFlat = i % 10 == 0 || i == 0;
      final bool isSquared = i == 7 || i == 2;
      final bool endsWith2 = i.toString().endsWith('2');
      final bool endsWith7 = i.toString().endsWith('7');

      if (isSquared || endsWith2 || endsWith7) setCellCount(2, 2);
      if (isFlat) setCellCount(3, 1);
    }

    if (type == GridAsymmetryType.ranking) {
      final bool isFirst = i == 0;
      final bool isSecondOrThird = i == 1 || i == 2;
      setCellCount(2, 0.36);
      if (isFirst) setCellCount(2, 0.7);
      if (isSecondOrThird) setCellCount(1, 0.75);
    }

    return StaggeredTile.count(crossAxisCellCount, mainAxisCellCount);
  }
}
