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

import 'package:df_type/df_type.dart' show FutureOrController;
import 'package:flutter/foundation.dart'
    show kDebugMode, mustCallSuper, nonVirtual;

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
  Set<_ToCloseResource<dynamic>> get toCloseResources =>
      Set.unmodifiable(_toCloseResources);

  final Set<_ToCloseResource<dynamic>> _toCloseResources = {};

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
  T willClose<T>(T resource, {_OnBeforeCallback<T>? onBeforeClose}) {
    // Verify that the resource has a close method in debug mode.
    _verifyCloseMethod(resource);
    final disposable = (
      resource: resource as dynamic,
      onBeforeClose:
          onBeforeClose != null ? (dynamic e) => onBeforeClose(e as T) : null,
    );

    // Check for any duplicate resource.
    final duplicate =
        _toCloseResources.where((e) => e.resource == resource).firstOrNull;

    if (duplicate != null) {
      if (kDebugMode) {
        // Throw an error in debug mode to inform the developer of duplicate
        // calls to `willClose()` on the same resource.
        throw WillAlreadyCloseDebugError(disposable);
      }
      // Remove the duplicate resource from the set.
      _toCloseResources.remove(duplicate);
    }

    // Add the new resource to the set. If there was a duplicate, it may
    // have had a different onBeforeClose callback. This will update it.
    _toCloseResources.add(disposable);

    return resource;
  }

  @mustCallSuper
  @override
  FutureOr<void> close() {
    final foc = FutureOrController<void>();

    try {
      // Call the parent's close method.
      foc.add((_) => super.close());

      for (final disposable in _toCloseResources) {
        final resource = disposable.resource;
        // Skip invalid resources.
        if (!hasValidCloseMethod(resource)) continue;

        // Attempt to call onBeforeClose, catching and copying any exceptions.
        Object? onBeforeCloseError;
        try {
          foc.add((_) => disposable.onBeforeClose?.call(resource));
        } catch (e) {
          onBeforeCloseError = e;
        }

        // Attempt to call close on the resource.
        foc.add((_) => resource.close());

        // If successful, rethrow any exception from onBeforeClose.
        if (onBeforeCloseError != null) {
          throw onBeforeCloseError;
        }
      }
    } catch (e) {
      // Collect exceptions to throw them all at the end, ensuring close gets
      // called on all resources.
      foc.addException(e);
    }

    // Return a Future or complete synchronously.
    return foc.complete();
  }

  /// Throws [NoCloseMethodDebugError] if [resource] does not have a `close`
  /// method that's either `void Function()` or `Future<void> Function()`.
  static void _verifyCloseMethod(dynamic resource) {
    if (kDebugMode && !hasValidCloseMethod(resource)) {
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

/// An [Error] thrown when `willClose()` has already been called on
/// a resource.
///
/// Informs the developer that there are duplicate calls of `willClose()`
/// on a [resource].
final class WillAlreadyCloseDebugError<T> extends Error {
  final T resource;

  WillAlreadyCloseDebugError(this.resource);

  @override
  String toString() => '[$WillAlreadyCloseDebugError] willClose has already '
      'been called on the resource ${resource.hashCode} and of type $T.';
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A mixin that adds a [close] method to a class.
mixin CloseMixin {
  /// Override to define the close operation.
  FutureOr<void> close();
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

typedef _ToCloseResource<T> = ({
  T resource,
  _OnBeforeCallback<T>? onBeforeClose,
});

typedef _FutureOrCallback<T> = FutureOr<void> Function();
typedef _OnBeforeCallback<T> = FutureOr<void> Function(T resource);
