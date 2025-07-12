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

extension WillCloseOnBuildContextX on BuildContext {
  /// Marks the [resource] for close.
  ///
  /// This allows you to mark resources for close at the time of their
  /// definition within the class, making your code more concise.
  ///
  /// You can optionally provide an [onBeforeClose] callback to be called
  /// immediately before `close`.
  ///
  /// The resource must have a `close` method. If the resource does not, a
  /// [NoCloseMethodDebugError] will be thrown in [kDebugMode].
  ///
  /// Returns the resource back to allow for easy chaining or assignment.
  T willClose<T>(T resource, {_OnBeforeCloseCallback<T>? onBeforeClose}) {
    final instance = _WillClose();
    instance.willClose(resource, onBeforeClose: onBeforeClose);
    if (widget is AttachableMixin) {
      final attachable = widget as AttachableMixin;
      return attachable.attach(
        this,
        resource,
        key: resource.hashCode,
        onDetach: (resource) {
          instance.close();
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
          instance.close();
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

class _WillClose extends _Close with WillCloseMixin {}

class _Close with CloseMixin {
  @override
  FutureOr<void> close() {}
}

typedef _OnBeforeCloseCallback<T> = FutureOr<void> Function(T resource);
