import 'package:flutter/material.dart';

import 'finger_aware_listener.dart';

class CustomFingerListViewController {
  final int fingerCount;
  final _fingerAwareListener = FingerAwareListener();

  bool _lastShouldScrollable = false;

  CustomFingerListViewController({required this.fingerCount});

  bool _updateShouldScrollable() {
    _lastShouldScrollable =
        _fingerAwareListener.info.currentPointersCount == fingerCount;
    return _lastShouldScrollable;
  }
}

class CustomFingerListViewParent extends StatelessWidget {
  final CustomFingerListViewController controller;
  final Widget child;

  const CustomFingerListViewParent(
      {Key? key, required this.child, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MuxListener(
      onPointer: controller._fingerAwareListener.handlePointer,
      child: child,
    );
  }
}

// This sub-class should have some boilerplate code, e.g. look at [NeverScrollableScrollPhysics] to see it
/// NOTE (WARN): This is a HACK, VIOLATING what the comments said for `applyPhysicsToUserOffset`. But works well for me.
class CustomFingerScrollPhysics extends ScrollPhysics {
  final CustomFingerListViewController controller;

  const CustomFingerScrollPhysics(
      {ScrollPhysics? parent, required this.controller})
      : super(parent: parent);

  @override
  CustomFingerScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomFingerScrollPhysics(
        controller: controller, parent: buildParent(ancestor));
  }

  /// NOTE This **HACK** is actually **VIOLATING** what the comment says!
  /// The comment in [ScrollPhysics.applyPhysicsToUserOffset] says:
  /// "This method must not adjust parts of the offset that are entirely within
  ///  the bounds described by the given `position`."
  /// In addition, when looking at [BouncingScrollPhysics.applyPhysicsToUserOffset],
  /// we see they directly return the original `offset` when `!position.outOfRange`
  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    if (controller._updateShouldScrollable()) {
      // When k fingers are dragging, the speed is actually *k* times the normal speed. So we divide it by k.
      // (see https://github.com/flutter/flutter/issues/11884)
      final currNumFinger =
          controller._fingerAwareListener.info.currentRunSeenPointers?.length ??
              1;
      return offset / currNumFinger;
    } else {
      return 0.0;
    }
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // When this method is called, the fingers seem to all *have left* the screen. Thus we cannot calculate the
    // current information, but should use the previous cache.
    if (controller._lastShouldScrollable) {
      return super.createBallisticSimulation(position, velocity);
    } else {
      return null;
    }
  }
}
