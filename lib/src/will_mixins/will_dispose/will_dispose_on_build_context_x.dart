//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Dart/Flutter (DF) Packages by dev-cetera.com & contributors. The use of this
// source code is governed by an MIT-style license described in the LICENSE
// file located in this project's root directory.
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

extension WillDisposeOnBuildContextX on BuildContext {
  /// Marks the [resource] for dispose.
  ///
  /// This allows you to mark resources for dispose at the time of their
  /// definition within the class, making your code more concise.
  ///
  /// You can optionally provide an [onBeforeDispose] callback to be called
  /// immediately before `dispose`.
  ///
  /// The resource must have a `dispose` method. If the resource does not, a
  /// [NoDisposeMethodDebugError] will be thrown in [kDebugMode].
  ///
  /// Returns the resource back to allow for easy chaining or assignment.
  T willDispose<T>(T resource, {_OnBeforeDisposeCallback<T>? onBeforeDispose}) {
    final instance = _WillDispose();
    instance.willDispose(resource, onBeforeDispose: onBeforeDispose);
    if (widget is AttachableMixin) {
      final attachable = widget as AttachableMixin;
      return attachable.attach(
        this,
        resource,
        key: resource.hashCode,
        onDetach: (resource) {
          instance.dispose();
        },
      );
    } else {
      if (kDebugMode) {
        final consideration =
            {
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
          instance.dispose();
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

class _WillDispose extends _Dispose with WillDisposeMixin {}

class _Dispose with DisposeMixin {
  @override
  FutureOr<void> dispose() {}
}

typedef _OnBeforeDisposeCallback<T> = FutureOr<void> Function(T resource);
