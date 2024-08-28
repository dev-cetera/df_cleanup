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

/// A mixin that simplifies resource dispose for a class.
///
/// This allows you to mark resources for dispose at the time of their
/// definition within the class, making your code more concise.
///
/// When the class's [dispose] method is called, the `dispose` method will be
/// invoked on each resource wrapped with [willDispose].
mixin WillDisposeMixin on DisposeMixin {
  /// The list of resources marked for dispose via [willDispose].
  List<ToDisposeResource> get toDisposeResources => List.unmodifiable(_toDisposeResources);

  final List<ToDisposeResource> _toDisposeResources = [];

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
  T willDispose<T>(T resource, {_FutureOrCallback? onBeforeDispose}) {
    // Verify that the resource has a dispose method in debug mode.
    if (kDebugMode) {
      _verifyDisposeMethod(resource);
    }
    final disposable = (
      resource: resource,
      onBeforeDispose: onBeforeDispose,
    );
    _toDisposeResources.add(disposable);
    
    return resource;
  }

  /// Calls `dispose` on each resource wrapped with [willDispose].
  @mustCallSuper
  @override
  FutureOr<void> dispose() async {
    // Call the parent's dispose method.
    await super.dispose();

    final exceptions = <Object>[];
    try {
      for (final disposable in _toDisposeResources) {
        final resource = disposable.resource;
        // Skip invalid resources.
        if (!hasValidDisposeMethod(resource)) continue;

        // Attempt to call onBeforeDispose, catching and copying any exceptions.
        Object? onBeforeDisposeError;
        try {
          await disposable.onBeforeDispose?.call();
        } catch (e) {
          onBeforeDisposeError = e;
        }

        // Attempt to call dispose on the resource.
        resource.dispose();

        // If successful, rethrow any exception from onBeforeDispose.
        if (onBeforeDisposeError != null) {
          throw onBeforeDisposeError;
        }
      }
    } catch (e) {
      // Collect exceptions to throw them all at the end, ensuring dispose gets
      // called on all resources.
      exceptions.add(e);
    }

    // Throw any remaining errors.
    if (exceptions.isNotEmpty) {
      throw exceptions.first;
    }
  }

  /// Throws [NoDisposeMethodDebugError] if [resource] does not have a `dispose`
  /// method that's either `void Function()` or `Future<void> Function()`.
  static void _verifyDisposeMethod(dynamic resource) {
    if (!hasValidDisposeMethod(resource)) {
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

typedef ToDisposeResource = ({
  dynamic resource,
  _FutureOrCallback? onBeforeDispose,
});

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

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A mixin that adds a [dispose] method to a class.
mixin DisposeMixin {
  /// Override to define the dispose operation.
  FutureOr<void> dispose();
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

typedef _FutureOrCallback = FutureOr<void> Function();
