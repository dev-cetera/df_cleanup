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

/// A mixin that simplifies resource stop for a class.
///
/// This allows you to mark resources for stop at the time of their
/// definition within the class, making your code more concise.
///
/// When the class's [stop] method is called, the `stop` method will be
/// invoked on each resource wrapped with [willStop].
mixin WillStopMixin on StopMixin {
  /// The list of resources marked for stop via [willStop].
  List<ToStopResource> get toStopResources => List.unmodifiable(_toStopResources);

  final List<ToStopResource> _toStopResources = [];

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
  T willStop<T>(T resource, {_FutureOrCallback? onBeforeStop}) {
    // Verify that the resource has a stop method in debug mode.
    if (kDebugMode) {
      _verifyStopMethod(resource);
    }
    final disposable = (
      resource: resource,
      onBeforeStop: onBeforeStop,
    );
    _toStopResources.add(disposable);

    return resource;
  }

  /// Calls `stop` on each resource wrapped with [willStop].
  @mustCallSuper
  @override
  FutureOr<void> stop() async {
    // Call the parent's stop method.
    await super.stop();

    final exceptions = <Object>[];
    try {
      for (final disposable in _toStopResources) {
        final resource = disposable.resource;
        // Skip invalid resources.
        if (!hasValidStopMethod(resource)) continue;

        // Attempt to call onBeforeStop, catching and copying any exceptions.
        Object? onBeforeStopError;
        try {
          await disposable.onBeforeStop?.call();
        } catch (e) {
          onBeforeStopError = e;
        }

        // Attempt to call stop on the resource.
        resource.stop();

        // If successful, rethrow any exception from onBeforeStop.
        if (onBeforeStopError != null) {
          throw onBeforeStopError;
        }
      }
    } catch (e) {
      // Collect exceptions to throw them all at the end, ensuring stop gets
      // called on all resources.
      exceptions.add(e);
    }

    // Throw any remaining errors.
    if (exceptions.isNotEmpty) {
      throw exceptions.first;
    }
  }

  /// Throws [NoStopMethodDebugError] if [resource] does not have a `stop`
  /// method that's either `void Function()` or `Future<void> Function()`.
  static void _verifyStopMethod(dynamic resource) {
    if (!hasValidStopMethod(resource)) {
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

typedef ToStopResource = ({
  dynamic resource,
  _FutureOrCallback? onBeforeStop,
});

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

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A mixin that adds a [stop] method to a class.
mixin StopMixin {
  /// Override to define the stop operation.
  FutureOr<void> stop();
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

typedef _FutureOrCallback = FutureOr<void> Function();
