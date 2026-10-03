import 'package:flutter/material.dart';
import 'rescue_state.dart';

class RescueScope extends InheritedNotifier<RescueGridState> {
  const RescueScope({
    super.key,
    required RescueGridState state,
    required super.child,
  }) : super(notifier: state);

  static RescueGridState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<RescueScope>();
    assert(scope != null, 'No RescueScope found in context');
    return scope!.notifier!;
  }
}

