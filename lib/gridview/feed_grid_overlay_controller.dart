import 'package:flutter/material.dart';

/// Controls how to overlay of the feed grid widget behaves.
class FeedGridViewOverlayController {
  // ignore: public_member_api_docs
  FeedGridViewOverlayController({
    required this.animationController,
    this.ignorePointer,
    this.color = Colors.black,
    this.maxOpacity = 0.95,
  }) : assert(maxOpacity >= 0 && maxOpacity <= 1.0, '') {}

  /// The inner animation controller of the overlay controller
  final AnimationController animationController;

  /// If the taps on the grid should be ignored or not
  final bool? ignorePointer;

  /// The max opacity that the overlay can have
  final double maxOpacity;

  /// The color of the overlay, usually set to black.
  final Color color;

  /// Dynamic Opacity for the Feed Overlay
  double get opacity => maxOpacity * animationController.value;

  /// Getter that controls whether or not the widget gestures should be ignored
  bool get ignoringPointer => ignorePointer ?? opacity > 0.00;
}
