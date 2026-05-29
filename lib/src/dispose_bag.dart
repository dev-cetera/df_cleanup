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

import 'dart:async' show FutureOr, Future, Zone;

import 'package:meta/meta.dart' show nonVirtual;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A signature for cleanup callbacks. May return a [Future] for async cleanup.
typedef DisposeFn = FutureOr<void> Function();

/// A signature for cleanup callbacks that receive the resource as an argument.
typedef DisposeFnOf<T> = FutureOr<void> Function(T resource);

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A collection of cleanup callbacks that are run together on [dispose].
///
/// Disposers run in **LIFO** order (last registered runs first), mirroring
/// stack semantics so that resources can be torn down in the reverse order
/// they were set up.
///
/// [dispose] is idempotent. Calling it more than once is a no-op.
///
/// ### Example
/// ```dart
/// class MyService {
///   final _bag = DisposeBag();
///   late final _sub = _bag.register(stream.listen(_onData), (s) => s.cancel());
///
///   void dispose() => _bag.dispose();
/// }
/// ```
final class DisposeBag {
  DisposeBag();

  final List<DisposeFn> _disposers = [];
  bool _disposed = false;
  bool _disposing = false;

  /// Whether [dispose] has already completed.
  bool get isDisposed => _disposed;

  /// Whether [dispose] is currently running.
  bool get isDisposing => _disposing;

  /// The number of disposers currently registered.
  int get length => _disposers.length;

  /// Registers a raw cleanup callback.
  ///
  /// Throws [StateError] if the bag is already disposed or disposing.
  ///
  /// Returns [onDispose] for chaining.
  @nonVirtual
  DisposeFn add(DisposeFn onDispose) {
    _assertUsable();
    _disposers.add(onDispose);
    return onDispose;
  }

  /// Registers [resource] together with a function to invoke on dispose.
  ///
  /// Returns [resource] to allow chaining/assignment at declaration site.
  @nonVirtual
  T register<T>(T resource, DisposeFnOf<T> onDispose) {
    _assertUsable();
    _disposers.add(() => onDispose(resource));
    return resource;
  }

  /// Removes a previously registered disposer without running it.
  ///
  /// Returns `true` if [onDispose] was found and removed.
  @nonVirtual
  bool remove(DisposeFn onDispose) {
    return _disposers.remove(onDispose);
  }

  /// Runs every registered disposer in LIFO order.
  ///
  /// - Disposers that throw are caught and reported via
  ///   [Zone.current.handleUncaughtError] so that one failure does not block
  ///   the rest.
  /// - Returns synchronously (`null`) if no disposer is async; otherwise
  ///   returns a [Future] that completes after all async disposers settle.
  /// - Calling [dispose] more than once is a no-op.
  @nonVirtual
  FutureOr<void> dispose() {
    if (_disposed || _disposing) return null;
    _disposing = true;

    final pending = <Future<void>>[];
    for (var i = _disposers.length - 1; i >= 0; i--) {
      try {
        final result = _disposers[i]();
        if (result is Future<void>) {
          pending.add(
            result.catchError((Object e, StackTrace st) {
              Zone.current.handleUncaughtError(e, st);
            }),
          );
        }
      } catch (e, st) {
        Zone.current.handleUncaughtError(e, st);
      }
    }
    _disposers.clear();

    if (pending.isEmpty) {
      _disposed = true;
      _disposing = false;
      return null;
    }
    return Future.wait(pending).then((_) {
      _disposed = true;
      _disposing = false;
    });
  }

  void _assertUsable() {
    if (_disposed || _disposing) {
      throw StateError(
        'Cannot register cleanup on a DisposeBag that has been disposed.',
      );
    }
  }
}
