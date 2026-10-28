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

import 'package:meta/meta.dart' show nonVirtual, mustCallSuper;

import 'dispose_bag.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A mixin that lets a class declare resources for cleanup at the site of
/// their definition, without writing per-resource boilerplate in [cleanup].
///
/// Use the explicit verb-matched methods when you know the resource's
/// teardown API:
///
/// - [willDispose] — resources with a `dispose` method (e.g. [ChangeNotifier],
///   [TextEditingController], [FocusNode], [AnimationController]).
/// - [willClose]   — resources with a `close` method (e.g. [StreamController],
///   [Sink], [HttpClient]).
/// - [willCancel]  — resources with a `cancel` method (e.g. [Timer],
///   [StreamSubscription]).
/// - [willStop]    — resources with a `stop` method.
///
/// Or use [willCleanup] to auto-detect among `dispose`/`close`/`cancel`/`stop`
/// (in that order), or to provide an explicit `onCleanup` callback.
///
/// For anything else, pass a raw callback to [addCleanup].
///
/// In debug builds, calling the same `will*` method twice on the same
/// resource throws [WillAlreadyRegisteredDebugError]. In release builds the
/// later registration silently replaces the earlier one.
///
/// Subclasses must implement [cleanup] (or use the Flutter-side `CleanupState`
/// which wires this into `State.dispose()` for you).
///
/// ### Example
/// ```dart
/// class CounterController with WillCleanupMixin {
///   late final value = willDispose(ValueNotifier<int>(0));
///   late final ticker = willCancel(Timer.periodic(
///     const Duration(seconds: 1),
///     (_) => value.value++,
///   ));
///
///   @override
///   FutureOr<void> cleanup() => super.cleanup();
/// }
/// ```
mixin WillCleanupMixin {
  final DisposeBag _bag = DisposeBag();

  /// The underlying bag. Useful for sharing cleanup scope with collaborators.
  @nonVirtual
  DisposeBag get disposeBag => _bag;

  /// Resources currently registered for cleanup. Read-only snapshot.
  @nonVirtual
  Iterable<Object?> get registeredResources =>
      List.unmodifiable(_registered.keys);

  /// Maps registered resources → their slot in [_bag]'s disposer list so that
  /// duplicate registrations can replace (release) the prior one.
  final Map<Object, DisposeFn> _registered = {};

  /// Whether [cleanup] has already completed.
  @nonVirtual
  bool get isCleanedUp => _bag.isDisposed;

  // ───────────────────────────────────────────────────────────────────────────
  // Explicit verb-matched registrations.
  // ───────────────────────────────────────────────────────────────────────────

  /// Registers [resource] to have its `dispose()` method invoked on cleanup.
  ///
  /// [onBeforeDispose] runs immediately before `dispose()`.
  ///
  /// Throws [NoCleanupMethodDebugError] in debug if [resource] has no
  /// matching method, and [WillAlreadyRegisteredDebugError] in debug if
  /// already registered.
  @nonVirtual
  T willDispose<T>(T resource, {DisposeFnOf<T>? onBeforeDispose}) {
    return _registerWithMethod<T>(
      resource,
      _CleanupMethod.dispose,
      onBefore: onBeforeDispose,
    );
  }

  /// Registers [resource] to have its `close()` method invoked on cleanup.
  ///
  /// [onBeforeClose] runs immediately before `close()`.
  @nonVirtual
  T willClose<T>(T resource, {DisposeFnOf<T>? onBeforeClose}) {
    return _registerWithMethod<T>(
      resource,
      _CleanupMethod.close,
      onBefore: onBeforeClose,
    );
  }

  /// Registers [resource] to have its `cancel()` method invoked on cleanup.
  ///
  /// [onBeforeCancel] runs immediately before `cancel()`.
  @nonVirtual
  T willCancel<T>(T resource, {DisposeFnOf<T>? onBeforeCancel}) {
    return _registerWithMethod<T>(
      resource,
      _CleanupMethod.cancel,
      onBefore: onBeforeCancel,
    );
  }

  /// Registers [resource] to have its `stop()` method invoked on cleanup.
  ///
  /// [onBeforeStop] runs immediately before `stop()`.
  @nonVirtual
  T willStop<T>(T resource, {DisposeFnOf<T>? onBeforeStop}) {
    return _registerWithMethod<T>(
      resource,
      _CleanupMethod.stop,
      onBefore: onBeforeStop,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Smart / explicit registrations.
  // ───────────────────────────────────────────────────────────────────────────

  /// Registers [resource] with an explicit [onCleanup] callback, or — if
  /// [onCleanup] is `null` — auto-detects a `dispose`/`close`/`cancel`/`stop`
  /// method on [resource] (in that order).
  ///
  /// Throws [NoCleanupMethodDebugError] in debug if no callback is supplied
  /// and no matching method is found.
  @nonVirtual
  T willCleanup<T>(T resource, {DisposeFnOf<T>? onCleanup}) {
    if (onCleanup != null) {
      _registerCallback(resource, () => onCleanup(resource));
      return resource;
    }
    final detected = _detectMethod(resource);
    assert(
      detected != null,
      NoCleanupMethodDebugError(resource.runtimeType).toString(),
    );
    return _registerWithMethod<T>(resource, detected ?? _CleanupMethod.dispose);
  }

  /// Registers an arbitrary cleanup callback.
  ///
  /// Returns [onCleanup] so callers can store it and pass it back to
  /// [cancelCleanup] later if needed.
  @nonVirtual
  DisposeFn addCleanup(DisposeFn onCleanup) {
    _bag.add(onCleanup);
    return onCleanup;
  }

  /// Cancels a previously-registered cleanup callback so it won't run.
  ///
  /// Returns `true` if it was found and removed.
  @nonVirtual
  bool cancelCleanup(DisposeFn onCleanup) => _bag.remove(onCleanup);

  // ───────────────────────────────────────────────────────────────────────────
  // Lifecycle.
  // ───────────────────────────────────────────────────────────────────────────

  /// Runs every registered cleanup. See [DisposeBag.dispose].
  @mustCallSuper
  FutureOr<void> cleanup() {
    _registered.clear();
    return _bag.dispose();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Internals.
  // ───────────────────────────────────────────────────────────────────────────

  T _registerWithMethod<T>(
    T resource,
    _CleanupMethod method, {
    DisposeFnOf<T>? onBefore,
  }) {
    final teardown = _resolveMethod(resource, method);
    assert(
      teardown != null,
      NoCleanupMethodDebugError(resource.runtimeType, expected: method)
          .toString(),
    );
    final call = teardown ?? () {};
    _registerCallback(resource, () async {
      if (onBefore != null) await onBefore(resource);
      await call();
    });
    return resource;
  }

  void _registerCallback(Object? resource, DisposeFn fn) {
    if (resource != null) {
      final existing = _registered[resource];
      if (existing != null) {
        assert(false, WillAlreadyRegisteredDebugError(resource).toString());
        _bag.remove(existing);
      }
      _registered[resource] = fn;
    }
    _bag.add(fn);
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

enum _CleanupMethod {
  dispose('dispose'),
  close('close'),
  cancel('cancel'),
  stop('stop');

  const _CleanupMethod(this.name);
  final String name;
}

/// Returns `resource.<method>` if it exists and is a `FutureOr<void> Function()`.
DisposeFn? _resolveMethod(dynamic resource, _CleanupMethod method) {
  try {
    final dynamic m = switch (method) {
      _CleanupMethod.dispose => resource.dispose,
      _CleanupMethod.close => resource.close,
      _CleanupMethod.cancel => resource.cancel,
      _CleanupMethod.stop => resource.stop,
    };
    if (m is DisposeFn) return m;
  } on NoSuchMethodError {
    return null;
  }
  return null;
}

/// Tries `dispose`/`close`/`cancel`/`stop` in order.
_CleanupMethod? _detectMethod(dynamic resource) {
  for (final m in _CleanupMethod.values) {
    if (_resolveMethod(resource, m) != null) return m;
  }
  return null;
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Thrown (via [assert]) when a resource passed to one of the `will*`
/// methods does not expose a matching `FutureOr<void> Function()` teardown.
final class NoCleanupMethodDebugError extends Error {
  NoCleanupMethodDebugError(this.resourceType, {this.expected});

  final Type resourceType;

  /// The specific method that was expected, or `null` if [WillCleanupMixin]
  /// was auto-detecting.
  final Object? expected;

  @override
  String toString() {
    final what = expected == null
        ? 'a dispose/close/cancel/stop method'
        : "a '${expected is Enum ? (expected as Enum).name : expected}()' method";
    return '[NoCleanupMethodDebugError] $resourceType has no $what matching '
        'FutureOr<void> Function(). Use addCleanup() or willCleanup(resource, '
        'onCleanup: ...) to provide an explicit teardown.';
  }
}

/// Thrown (via [assert]) when the same resource is registered more than once.
///
/// In release the later registration silently replaces the earlier one.
final class WillAlreadyRegisteredDebugError extends Error {
  WillAlreadyRegisteredDebugError(this.resource);

  final Object resource;

  @override
  String toString() =>
      '[WillAlreadyRegisteredDebugError] cleanup already registered for '
      'resource ${resource.runtimeType}#${resource.hashCode}. '
      'The earlier registration will be replaced.';
}
