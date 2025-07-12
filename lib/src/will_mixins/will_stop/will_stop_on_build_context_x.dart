//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Copyright © dev-cetera.com & contributors.
//
// The use of this source code is governed by an MIT-style license described in
// the LICENSE file located in this project's root directory.
//
// See: https://opensource.org/license/mit
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import 'dart:async' show FutureOr;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/widgets.dart';

import '/src/_index.g.dart';

import '../../attachable_mixin/_attachable_mixin.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

extension WillStopOnBuildContextX on BuildContext {
  /// Marks the [resource] for stop.
  ///
  /// This allows you to mark resources for stop at the time of their
  /// definition within the class, making your code more concise.
  ///
  /// You can optionally provide an [onBeforeStop] callback to be called
  /// immediately before `stop`.
  ///
  /// The resource must have a `stop` method. If the resource does not, a
  /// [NoStopMethodDebugError] will be thrown in [kDebugMode].
  ///
  /// Returns the resource back to allow for easy chaining or assignment.
  T willStop<T>(T resource, {_OnBeforeStopCallback<T>? onBeforeStop}) {
    final instance = _WillStop();
    instance.willStop(resource, onBeforeStop: onBeforeStop);
    if (widget is AttachableMixin) {
      final attachable = widget as AttachableMixin;
      return attachable.attach(
        this,
        resource,
        key: resource.hashCode,
        onDetach: (resource) {
          instance.stop();
        },
      );
    } else {
      if (kDebugMode) {
        final consideration = {
              StatelessWidget: StatelessAttachableMixin,
              StatefulWidget: StatefulAttachableMixin,
            }[widget.runtimeType] ??
            AttachableMixin;
        _log(
          'Consider using $consideration with your widget "${widget.runtimeType}" for better performance.',
        );
      }

      return ContextStore.of(this).attach(
        resource,
        key: resource.hashCode,
        onDetach: (resource) {
          instance.stop();
        },
      );
    }
  }

  //
  //
  //

  static void _log(String message) {
    if (kDebugMode) {
      debugPrint('[willCancel] $message');
    }
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class _WillStop extends _Stop with WillStopMixin {}

class _Stop with StopMixin {
  @override
  FutureOr<void> stop() {}
}

typedef _OnBeforeStopCallback<T> = FutureOr<void> Function(T resource);
