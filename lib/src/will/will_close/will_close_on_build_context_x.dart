//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Dart/Flutter (DF) Packages by DevCetra.com & contributors. The use of this
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

import '/src/attachable/_attachable_mixin.dart';

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
  T willClose<T>(T resource, {_FutureOrCallback? onBeforeClose}) {
    final instance = _WillClose();
    instance.willClose(resource, onBeforeClose: onBeforeClose);
    if (widget is AttachableMixin) {
      final attachable = widget as AttachableMixin;
      return attachable.attach(
        this,
        resource,
        onDetach: (resource) {
          instance.close();
        },
      );
    } else {
      throw Exception(
        '[willDispose] The provided context is not associated with AttachableMixin. Please ensure your widget includes AttachableMixin.',
      );
      // The following needs more testing. It has some issues:
      // return ContextStore.of(this).attach(
      //   resource,
      //   key: resource.hashCode,
      //   onDetach: (resource) {
      //     instance.close();
      //   },
      // );
    }
  }
}

class _WillClose extends _Close with WillCloseMixin {}

class _Close with CloseMixin {
  @override
  FutureOr<void> close() {}
}

typedef _FutureOrCallback = FutureOr<void> Function();
