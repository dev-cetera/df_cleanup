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
import 'package:flutter/foundation.dart' show kDebugMode, mustCallSuper, nonVirtual;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A mixin that simplifies resource stop for a class.
///
/// This allows you to mark resources for stop at the time of their
/// definition within the class, making your code more concise.
///
/// When the class's [stop] method is called, the `stop` method will be
/// invoked on each resource wrapped with [willStop].
mixin WillStopMixin on StopMixin {
  /// The list of resources marked for stop via [willStop].
  Set<_ToStopResource<dynamic>> get toStopResources => Set.unmodifiable(_toStopResources);

  final Set<_ToStopResource<dynamic>> _toStopResources = {};

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
  @nonVirtual
  T willStop<T>(T resource, {_OnBeforeCallback<T>? onBeforeStop}) {
    // Verify that the resource has a stop method in debug mode.
    _verifyStopMethod(resource);
    final disposable = (
      resource: resource as dynamic,
      onBeforeStop: onBeforeStop != null ? (dynamic e) => onBeforeStop(e as T) : null,
    );

    // Check for any duplicate resource.
    final duplicate = _toStopResources.where((e) => e.resource == resource).firstOrNull;

    if (duplicate != null) {
      if (kDebugMode) {
        // Throw an error in debug mode to inform the developer of duplicate
        // calls to `willStop()` on the same resource.
        throw WillAlreadyStopDebugError(disposable);
      }
      // Remove the duplicate resource from the set.
      _toStopResources.remove(duplicate);
    }

    // Add the new resource to the set. If there was a duplicate, it may
    // have had a different onBeforeStop callback. This will update it.
    _toStopResources.add(disposable);

    return resource;
  }

  @mustCallSuper
  @override
  FutureOr<void> stop() {
    final foc = FutureOrController();

    try {
      // Call the parent's stop method.
      foc.add(super.stop());

      for (final disposable in _toStopResources) {
        final resource = disposable.resource;
        // Skip invalid resources.
        if (!hasValidStopMethod(resource)) continue;

        // Attempt to call onBeforeStop, catching and copying any exceptions.
        Object? onBeforeStopError;
        try {
          foc.add(disposable.onBeforeStop?.call(resource));
        } catch (e) {
          onBeforeStopError = e;
        }

        // Attempt to call stop on the resource.
        foc.add(resource.stop());

        // If successful, rethrow any exception from onBeforeStop.
        if (onBeforeStopError != null) {
          throw onBeforeStopError;
        }
      }
    } catch (e) {
      // Collect exceptions to throw them all at the end, ensuring stop gets
      // called on all resources.
      foc.addException(e);
    }

    // Return a Future or complete synchronously.
    return foc.complete();
  }

  /// Throws [NoStopMethodDebugError] if [resource] does not have a `stop`
  /// method that's either `void Function()` or `Future<void> Function()`.
  static void _verifyStopMethod(dynamic resource) {
    if (kDebugMode && !hasValidStopMethod(resource)) {
      throw NoStopMethodDebugError(resource.runtimeType);
    }
  }

  /// Checks if [resource] has a `stop` method that matches
  /// `FutureOr<void> Function()`.
  static bool hasValidStopMethod(dynamic resource) {
    try {
      final method = resource.stop;
      final isValid = method is _FutureOrCallback;
      return isValid;
    } on NoSuchMethodError {
      return false;
    }
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// An [Error] thrown when a type without a `stop` method is passed to
/// `willStop()`.
///
/// Informs the developer that the resource type cannot be properly stoped
/// using `willStop()`.
final class NoStopMethodDebugError extends Error {
  final Type resourceType;

  NoStopMethodDebugError(this.resourceType);

  @override
  String toString() {
    return '[$NoStopMethodDebugError] The type $resourceType cannot be used '
        'with willStop() as it has no "stop" method or one that conforms '
        'to $_FutureOrCallback.';
  }
}

/// An [Error] thrown when `willStop()` has already been called on
/// a resource.
///
/// Informs the developer that there are duplicate calls of `willStop()`
/// on a [resource].
final class WillAlreadyStopDebugError<T> extends Error {
  final T resource;

  WillAlreadyStopDebugError(this.resource);

  @override
  String toString() => '[$WillAlreadyStopDebugError] willStop has already '
      'been called on the resource ${resource.hashCode} and of type $T.';
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A mixin that adds a [stop] method to a class.
mixin StopMixin {
  /// Override to define the stop operation.
  FutureOr<void> stop();
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

typedef _ToStopResource<T> = ({
  T resource,
  _OnBeforeCallback<T>? onBeforeStop,
});

typedef _FutureOrCallback<T> = FutureOr<void> Function();
typedef _OnBeforeCallback<T> = FutureOr<void> Function(T resource);
