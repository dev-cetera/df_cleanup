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

import 'package:df_type/df_type.dart' show Waiter;
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
  Set<_ToCancelResource<dynamic>> get toCancelResources => Set.unmodifiable(_toCancelResources);

  final Set<_ToCancelResource<dynamic>> _toCancelResources = {};

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
  T willCancel<T>(T resource, {_OnBeforeCallback<T>? onBeforeCancel}) {
    // Verify that the resource has a cancel method in debug mode.
    _verifyCancelMethod(resource);
    final disposable = (
      resource: resource as dynamic,
      onBeforeCancel: onBeforeCancel != null ? (dynamic e) => onBeforeCancel(e as T) : null,
    );

    // Check for any duplicate resource.
    final duplicate = _toCancelResources.where((e) => e.resource == resource).firstOrNull;

    if (duplicate != null) {
      if (kDebugMode) {
        // Throw an error in debug mode to inform the developer of duplicate
        // calls to `willCancel()` on the same resource.
        throw WillAlreadyCancelDebugError(disposable);
      }
      // Remove the duplicate resource from the set.
      _toCancelResources.remove(duplicate);
    }

    // Add the new resource to the set. If there was a duplicate, it may
    // have had a different onBeforeCancel callback. This will update it.
    _toCancelResources.add(disposable);

    return resource;
  }

  @mustCallSuper
  @override
  FutureOr<void> cancel() {
    final waiter = Waiter<void>();
    waiter.add(super.cancel);
    for (final disposable in _toCancelResources) {
      final resource = disposable.resource;
      if (!hasValidCancelMethod(resource)) continue;
      waiter.add(() => disposable.onBeforeCancel?.call(resource));
      waiter.add(() => resource.cancel());
    }
    return waiter.wait();
  }

  /// Throws [NoCancelMethodDebugError] if [resource] does not have a `cancel`
  /// method that's either `void Function()` or `Future<void> Function()`.
  static void _verifyCancelMethod(dynamic resource) {
    if (kDebugMode && !hasValidCancelMethod(resource)) {
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

/// An [Error] thrown when `willCancel()` has already been called on
/// a resource.
///
/// Informs the developer that there are duplicate calls of `willCancel()`
/// on a [resource].
final class WillAlreadyCancelDebugError<T> extends Error {
  final T resource;

  WillAlreadyCancelDebugError(this.resource);

  @override
  String toString() => '[$WillAlreadyCancelDebugError] willCancel has already '
      'been called on the resource ${resource.hashCode} and of type $T.';
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A mixin that adds a [cancel] method to a class.
mixin CancelMixin {
  /// Override to define the cancel operation.
  FutureOr<void> cancel();
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

typedef _ToCancelResource<T> = ({
  T resource,
  _OnBeforeCallback<T>? onBeforeCancel,
});

typedef _FutureOrCallback<T> = FutureOr<void> Function();
typedef _OnBeforeCallback<T> = FutureOr<void> Function(T resource);
