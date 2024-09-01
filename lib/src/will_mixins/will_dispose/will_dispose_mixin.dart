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

/// A mixin that simplifies resource dispose for a class.
///
/// This allows you to mark resources for dispose at the time of their
/// definition within the class, making your code more concise.
///
/// When the class's [dispose] method is called, the `dispose` method will be
/// invoked on each resource wrapped with [willDispose].
mixin WillDisposeMixin on DisposeMixin {
  /// The list of resources marked for dispose via [willDispose].
  Set<_ToDisposeResource<dynamic>> get toDisposeResources =>
      Set.unmodifiable(_toDisposeResources);

  final Set<_ToDisposeResource<dynamic>> _toDisposeResources = {};

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
  @nonVirtual
  T willDispose<T>(T resource, {_OnBeforeCallback<T>? onBeforeDispose}) {
    // Verify that the resource has a dispose method in debug mode.
    _verifyDisposeMethod(resource);
    final disposable = (
      resource: resource as dynamic,
      onBeforeDispose: onBeforeDispose != null
          ? (dynamic e) => onBeforeDispose(e as T)
          : null,
    );

    // Check for any duplicate resource.
    final duplicate =
        _toDisposeResources.where((e) => e.resource == resource).firstOrNull;

    if (duplicate != null) {
      if (kDebugMode) {
        // Throw an error in debug mode to inform the developer of duplicate
        // calls to `willDispose()` on the same resource.
        throw WillAlreadyDisposeDebugError(disposable);
      }
      // Remove the duplicate resource from the set.
      _toDisposeResources.remove(duplicate);
    }

    // Add the new resource to the set. If there was a duplicate, it may
    // have had a different onBeforeDispose callback. This will update it.
    _toDisposeResources.add(disposable);

    return resource;
  }

  @mustCallSuper
  @override
  FutureOr<void> dispose() {
    final foc = FutureOrController<void>();

    try {
      // Call the parent's dispose method.
      foc.add((_) => super.dispose());

      for (final disposable in _toDisposeResources) {
        final resource = disposable.resource;
        // Skip invalid resources.
        if (!hasValidDisposeMethod(resource)) continue;

        // Attempt to call onBeforeDispose, catching and copying any exceptions.
        Object? onBeforeDisposeError;
        try {
          foc.add((_) => disposable.onBeforeDispose?.call(resource));
        } catch (e) {
          onBeforeDisposeError = e;
        }

        // Attempt to call dispose on the resource.
        foc.add((_) => resource.dispose());

        // If successful, rethrow any exception from onBeforeDispose.
        if (onBeforeDisposeError != null) {
          throw onBeforeDisposeError;
        }
      }
    } catch (e) {
      // Collect exceptions to throw them all at the end, ensuring dispose gets
      // called on all resources.
      foc.addException(e);
    }

    // Return a Future or complete synchronously.
    return foc.complete();
  }

  /// Throws [NoDisposeMethodDebugError] if [resource] does not have a `dispose`
  /// method that's either `void Function()` or `Future<void> Function()`.
  static void _verifyDisposeMethod(dynamic resource) {
    if (kDebugMode && !hasValidDisposeMethod(resource)) {
      throw NoDisposeMethodDebugError(resource.runtimeType);
    }
  }

  /// Checks if [resource] has a `dispose` method that matches
  /// `FutureOr<void> Function()`.
  static bool hasValidDisposeMethod(dynamic resource) {
    try {
      final method = resource.dispose;
      final isValid = method is _FutureOrCallback;
      return isValid;
    } on NoSuchMethodError {
      return false;
    }
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// An [Error] thrown when a type without a `dispose` method is passed to
/// `willDispose()`.
///
/// Informs the developer that the resource type cannot be properly disposeed
/// using `willDispose()`.
final class NoDisposeMethodDebugError extends Error {
  final Type resourceType;

  NoDisposeMethodDebugError(this.resourceType);

  @override
  String toString() {
    return '[$NoDisposeMethodDebugError] The type $resourceType cannot be used '
        'with willDispose() as it has no "dispose" method or one that conforms '
        'to $_FutureOrCallback.';
  }
}

/// An [Error] thrown when `willDispose()` has already been called on
/// a resource.
///
/// Informs the developer that there are duplicate calls of `willDispose()`
/// on a [resource].
final class WillAlreadyDisposeDebugError<T> extends Error {
  final T resource;

  WillAlreadyDisposeDebugError(this.resource);

  @override
  String toString() =>
      '[$WillAlreadyDisposeDebugError] willDispose has already '
      'been called on the resource ${resource.hashCode} and of type $T.';
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A mixin that adds a [dispose] method to a class.
mixin DisposeMixin {
  /// Override to define the dispose operation.
  FutureOr<void> dispose();
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

typedef _ToDisposeResource<T> = ({
  T resource,
  _OnBeforeCallback<T>? onBeforeDispose,
});

typedef _FutureOrCallback<T> = FutureOr<void> Function();
typedef _OnBeforeCallback<T> = FutureOr<void> Function(T resource);
