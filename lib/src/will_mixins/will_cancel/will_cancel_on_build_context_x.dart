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

extension WillCancelOnBuildContextX on BuildContext {
  /// Marks the [resource] for  cancel.
  ///
  /// This allows you to mark resources for  cancel at the time of their
  /// definition within the class, making your code more concise.
  ///
  /// You can optionally provide an [onBeforeCancel] callback to be called
  /// immediately before ` cancel`.
  ///
  /// The resource must have a ` cancel` method. If the resource does not, a
  /// [NoCancelMethodDebugError] will be thrown in [kDebugMode].
  ///
  /// Returns the resource back to allow for easy chaining or assignment.
  T willCancel<T>(T resource, {_OnBeforeCancelCallback<T>? onBeforeCancel}) {
    final instance = _WillCancel();
    instance.willCancel(resource, onBeforeCancel: onBeforeCancel);
    if (widget is AttachableMixin) {
      final attachable = widget as AttachableMixin;
      return attachable.attach(
        this,
        resource,
        key: resource.hashCode,
        onDetach: (resource) {
          instance.cancel();
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
          instance.cancel();
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

class _WillCancel extends _Cancel with WillCancelMixin {}

class _Cancel with CancelMixin {
  @override
  FutureOr<void> cancel() {}
}

typedef _OnBeforeCancelCallback<T> = FutureOr<void> Function(T resource);
