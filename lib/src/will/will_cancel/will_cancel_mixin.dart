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

/// A mixin that simplifies resource cancel for a class.
///
/// This allows you to mark resources for cancel at the time of their
/// definition within the class, making your code more concise.
///
/// When the class's [cancel] method is called, the `cancel` method will be
/// invoked on each resource wrapped with [willCancel].
mixin WillCancelMixin on CancelMixin {
  /// The list of resources marked for cancel via [willCancel].
  List<ToCancelResource> get toCancelResources => List.unmodifiable(_toCancelResources);

  final List<ToCancelResource> _toCancelResources = [];

  /// Marks the [resource] for cancel.
  ///
  /// This allows you to mark resources for cancel at the time of their
  /// definition within the class, making your code more concise.
  ///
  /// You can optionally provide an [onBeforeCancel] callback to be called
  /// immediately before `cancel`.
  ///
  /// The resource must have a `cancel` method. If the resource does not, a
  /// [NoCancelMethodDebugError] will be thrown in [kDebugMode].
  ///
  /// Returns the resource back to allow for easy chaining or assignment.
  @nonVirtual
  T willCancel<T>(T resource, {_FutureOrCallback? onBeforeCancel}) {
    // Verify that the resource has a cancel method in debug mode.
    if (kDebugMode) {
      _verifyCancelMethod(resource);
    }
    final disposable = (
      resource: resource,
      onBeforeCancel: onBeforeCancel,
    );
    _toCancelResources.add(disposable);

    return resource;
  }

  /// Calls `cancel` on each resource wrapped with [willCancel].
  @mustCallSuper
  @override
  FutureOr<void> cancel() async {
    // Call the parent's cancel method.
    await super.cancel();

    final exceptions = <Object>[];
    try {
      for (final disposable in _toCancelResources) {
        final resource = disposable.resource;
        // Skip invalid resources.
        if (!hasValidCancelMethod(resource)) continue;

        // Attempt to call onBeforeCancel, catching and copying any exceptions.
        Object? onBeforeCancelError;
        try {
          await disposable.onBeforeCancel?.call();
        } catch (e) {
          onBeforeCancelError = e;
        }

        // Attempt to call cancel on the resource.
        resource.cancel();

        // If successful, rethrow any exception from onBeforeCancel.
        if (onBeforeCancelError != null) {
          throw onBeforeCancelError;
        }
      }
    } catch (e) {
      // Collect exceptions to throw them all at the end, ensuring cancel gets
      // called on all resources.
      exceptions.add(e);
    }

    // Throw any remaining errors.
    if (exceptions.isNotEmpty) {
      throw exceptions.first;
    }
  }

  /// Throws [NoCancelMethodDebugError] if [resource] does not have a `cancel`
  /// method that's either `void Function()` or `Future<void> Function()`.
  static void _verifyCancelMethod(dynamic resource) {
    if (!hasValidCancelMethod(resource)) {
      throw NoCancelMethodDebugError(resource.runtimeType);
    }
  }

  /// Checks if [resource] has a `cancel` method that matches
  /// `FutureOr<void> Function()`.
  static bool hasValidCancelMethod(dynamic resource) {
    try {
      final method = resource.cancel;
      final isValid = method is _FutureOrCallback;
      return isValid;
    } on NoSuchMethodError {
      return false;
    }
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

typedef ToCancelResource = ({
  dynamic resource,
  _FutureOrCallback? onBeforeCancel,
});

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// An [Error] thrown when a type without a `cancel` method is passed to
/// `willCancel()`.
///
/// Informs the developer that the resource type cannot be properly canceled
/// using `willCancel()`.
final class NoCancelMethodDebugError extends Error {
  final Type resourceType;

  NoCancelMethodDebugError(this.resourceType);

  @override
  String toString() {
    return '[$NoCancelMethodDebugError] The type $resourceType cannot be used '
        'with willCancel() as it has no "cancel" method or one that conforms '
        'to $_FutureOrCallback.';
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A mixin that adds a [cancel] method to a class.
mixin CancelMixin {
  /// Override to define the cancel operation.
  FutureOr<void> cancel();
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

typedef _FutureOrCallback = FutureOr<void> Function();
