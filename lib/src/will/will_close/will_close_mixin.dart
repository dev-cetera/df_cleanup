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

import 'package:flutter/foundation.dart' show kDebugMode, mustCallSuper, nonVirtual;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A mixin that simplifies resource close for a class.
///
/// This allows you to mark resources for close at the time of their
/// definition within the class, making your code more concise.
///
/// When the class's [close] method is called, the `close` method will be
/// invoked on each resource wrapped with [willClose].
mixin WillCloseMixin on CloseMixin {
  /// The list of resources marked for close via [willClose].
  List<ToCloseResource> get toCloseResources => List.unmodifiable(_oCloseResources);

  final List<ToCloseResource> _oCloseResources = [];

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
  @nonVirtual
  T willClose<T>(T resource, {_FutureOrCallback? onBeforeClose}) {
    // Verify that the resource has a close method in debug mode.
    if (kDebugMode) {
      _verifyCloseMethod(resource);
    }
    final disposable = (
      resource: resource,
      onBeforeClose: onBeforeClose,
    );
    _oCloseResources.add(disposable);

    return resource;
  }

  /// Calls `close` on each resource wrapped with [willClose].
  @mustCallSuper
  @override
  FutureOr<void> close() async {
    // Call the parent's close method.
    await super.close();

    final exceptions = <Object>[];
    try {
      for (final disposable in _oCloseResources) {
        final resource = disposable.resource;
        // Skip invalid resources.
        if (!hasValidCloseMethod(resource)) continue;

        // Attempt to call onBeforeClose, catching and copying any exceptions.
        Object? onBeforeCloseError;
        try {
          await disposable.onBeforeClose?.call();
        } catch (e) {
          onBeforeCloseError = e;
        }

        // Attempt to call close on the resource.
        resource.close();

        // If successful, rethrow any exception from onBeforeClose.
        if (onBeforeCloseError != null) {
          throw onBeforeCloseError;
        }
      }
    } catch (e) {
      // Collect exceptions to throw them all at the end, ensuring close gets
      // called on all resources.
      exceptions.add(e);
    }

    // Throw any remaining errors.
    if (exceptions.isNotEmpty) {
      throw exceptions.first;
    }
  }

  /// Throws [NoCloseMethodDebugError] if [resource] does not have a `close`
  /// method that's either `void Function()` or `Future<void> Function()`.
  static void _verifyCloseMethod(dynamic resource) {
    if (!hasValidCloseMethod(resource)) {
      throw NoCloseMethodDebugError(resource.runtimeType);
    }
  }

  /// Checks if [resource] has a `close` method that matches
  /// `FutureOr<void> Function()`.
  static bool hasValidCloseMethod(dynamic resource) {
    try {
      final method = resource.close;
      final isValid = method is _FutureOrCallback;
      return isValid;
    } on NoSuchMethodError {
      return false;
    }
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

typedef ToCloseResource = ({
  dynamic resource,
  _FutureOrCallback? onBeforeClose,
});

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// An [Error] thrown when a type without a `close` method is passed to
/// `willClose()`.
///
/// Informs the developer that the resource type cannot be properly closeed
/// using `willClose()`.
final class NoCloseMethodDebugError extends Error {
  final Type resourceType;

  NoCloseMethodDebugError(this.resourceType);

  @override
  String toString() {
    return '[$NoCloseMethodDebugError] The type $resourceType cannot be used '
        'with willClose() as it has no "close" method or one that conforms '
        'to $_FutureOrCallback.';
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A mixin that adds a [close] method to a class.
mixin CloseMixin {
  /// Override to define the close operation.
  FutureOr<void> close();
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

typedef _FutureOrCallback = FutureOr<void> Function();
