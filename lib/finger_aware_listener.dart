import 'package:flutter/material.dart';

class FingerAwareListener {
  final info = FingerAwareInfo();

  final dynamic Function(PointerEvent e, dynamic extra, FingerAwareInfo info,
      bool isNewPointer)? onPointerDown;
  final dynamic Function(PointerEvent e, dynamic extra, FingerAwareInfo info)?
      onPointerOther;

  FingerAwareListener({
    this.onPointerDown,
    this.onPointerOther,
  });

  dynamic handlePointer(PointerEvent e, [dynamic extra]) {
    if (e is PointerDownEvent) {
      info.currentRunSeenPointers ??= Set();
      final isNewPointer = !info.currentRunSeenPointers!.contains(e.pointer);

      info.activePointers.add(e.pointer);
      info.currentRunSeenPointers!.add(e.pointer);

      return onPointerDown?.call(e, extra, info, isNewPointer);
    } else if (e is PointerUpEvent) {
      info.activePointers.remove(e.pointer);

      final result = onPointerOther?.call(e, extra, info);

      if (info.activePointers.isEmpty) {
        info.currentRunSeenPointers = null;
      }

      return result;
    } else {
      return onPointerOther?.call(e, extra, info);
    }
  }
}

class FingerAwareInfo {
  final List<int> activePointers = [];

  Set<int>? currentRunSeenPointers;

  bool get isCurrentRunMultiFingerUpToNow =>
      (currentRunSeenPointers?.length ?? 0) > 1;
  int get currentPointersCount => currentRunSeenPointers?.length ?? 0;
}

class WantSingleFingerListener {
  late FingerAwareListener _fingerAwareListener;

  final dynamic Function(PointerEvent e, dynamic extra) onSingleFingerPointer;
  final dynamic Function(dynamic extra) onSecondFingerFirstlyAppear;

  WantSingleFingerListener({
    required this.onSingleFingerPointer,
    required this.onSecondFingerFirstlyAppear,
  }) {
    _fingerAwareListener = FingerAwareListener(
      onPointerDown: (e, extra, info, isNewPointer) {
        if (!info.isCurrentRunMultiFingerUpToNow) {
          return onSingleFingerPointer?.call(e, extra);
        } else if (info.isCurrentRunMultiFingerUpToNow && isNewPointer) {
          return onSecondFingerFirstlyAppear?.call(extra);
        }
        return null;
      },
      onPointerOther: (e, extra, info) {
        if (!info.isCurrentRunMultiFingerUpToNow) {
          return onSingleFingerPointer?.call(e, extra);
        }
        return null;
      },
    );
  }

  dynamic handlePointer(PointerEvent e, [dynamic extra]) =>
      _fingerAwareListener.handlePointer(e, extra);
}

class MuxListener extends StatelessWidget {
  final Widget child;
  final void Function(PointerEvent e) onPointer;

  const MuxListener({Key? key, required this.onPointer, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: onPointer,
      onPointerMove: onPointer,
      onPointerUp: onPointer,
      onPointerCancel: onPointer,
      child: child,
    );
  }
}
