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
import 'dart:collection';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/widgets.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Provides a way to [attach], [retrieve], and [detach] data tied to a specific
/// [BuildContext] and key, ensuring effective management of context-bound state
/// throughout the widget tree lifecycle.
///
/// ---
///
/// ### Example:
///
/// ```dart
/// final store = ContextStore.of(context);
/// store.attach<MyData>(myData);
/// final data = store.get<MyData>();
/// ```

class AssociatedContextStore {
  //
  //
  //

  /// The `BuildContext` associated with the data.
  final BuildContext context;

  /// Creates a `ContextStore` instance associated with the provided [context].
  const AssociatedContextStore(this.context);

  /// Attaches data of type [T] to [context] with a [key].
  ///
  /// If key is `null`, the type [T] is used as the key. The [key] parameter is
  /// deliberately marked as [required] to ensure the developer deliberately
  /// decides whether to provide a key or set it as `null`.
  ///
  /// Optionally, an [onDetach] callback can be provided, which is called when
  /// the data is detached from the store.
  T attach<T>(
    T data, {
    required dynamic key,
    void Function(T data)? onDetach,
  }) {
    return ContextStore.instance.attach(
      context,
      data,
      key: key,
      onDetach: onDetach,
    );
  }

  /// Retrieves data of type [T] associated with the [context].
  ///
  /// If key is `null`, the type [T] is used as the key. The [key] parameter is
  /// deliberately marked as [required] to ensure the developer deliberately
  /// decides whether to provide a key or set it as `null`.
  ///
  /// Returns the data if it exists, otherwise `null`.
  T? retrieve<T>({
    required dynamic key,
  }) {
    return ContextStore.instance.retrieve<T>(
      context,
      key: key,
    );
  }

  /// Detaches and removes data of type [T] associated with [context].
  ///
  /// If key is `null`, the type [T] is used as the key. The [key] parameter is
  /// deliberately marked as [required] to ensure the developer deliberately
  /// decides whether to provide a key or set it as `null`.
  ///
  /// Returns the removed data if or `null` if it didn't exist.
  ContextStoreData<T>? detach<T>({
    required dynamic key,
  }) {
    return ContextStore.instance.detach<T>(
      context,
      key: key,
    );
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class ContextStore {
  //
  //
  //

  Duration contextCheckDelay = const Duration(seconds: 1);

  //
  //
  //

  static final instance = ContextStore._();
  ContextStore._();

  //
  //
  //

  /// Creates a `ContextStore` instance associated with the provided [context].
  static AssociatedContextStore of(BuildContext context) =>
      AssociatedContextStore(context);

  //
  //
  //

  final _store = ContextStoreMap<dynamic>();
  ContextStoreMap<dynamic> get store => ContextStoreMap.of(_store);

  //
  //
  //

  T attach<T>(
    BuildContext context,
    T data, {
    required dynamic key,
    void Function(T data)? onDetach,
  }) {
    final keyOrType = key ?? T;

    // Ensure the context entry exists in the map and check if it existed.
    final contextDataMap = _store[context] ??= HashMap();
    final didContextMapExist = contextDataMap.isNotEmpty;

    // Check if the data for the given key is already present.
    if (contextDataMap.containsKey(keyOrType)) {
      _log(
        'Data for context hash ${context.hashCode} and key hash ${keyOrType.hashCode} is already attached.',
      );
    } else {
      // Store the data in the map.
      _store[context]![keyOrType] = (
        data: data,
        onDetach: onDetach != null ? (e) => onDetach(e as T) : null,
      );
      _log(
        'Attached context data associated with context hash ${context.hashCode} and key hash ${keyOrType.hashCode}',
      );
      _log(
        'Context data map length: ${contextDataMap.length}',
      );
      _log(
        'Store map length: ${_store.length}',
      );

      // Schedule a context check if it's not already being checked.
      if (!didContextMapExist) {
        _scheduleContextCheck(context);
      }
    }

    return data;
  }

  //
  //
  //

  T? retrieve<T>(
    BuildContext context, {
    required dynamic key,
  }) {
    final keyOrType = key ?? T;
    return _store[context]?[keyOrType]?.data as T?;
  }

  //
  //
  //

  void detachAll() {
    for (var context in _store.keys.toList()) {
      final contextDataMap = _store[context];
      if (contextDataMap != null) {
        for (var key in contextDataMap.keys.toList()) {
          _detach<dynamic>(context, key: key);
        }
      }
    }
  }

  //
  //
  //

  ContextStoreData<T>? detach<T>(
    BuildContext context, {
    required dynamic key,
  }) {
    return _detach<T>(context, key: key);
  }

  //
  //
  //

  ContextStoreData<T>? _detach<T>(
    BuildContext context, {
    required dynamic key,
  }) {
    final keyOrType = key ?? T;

    // Try and remove associated data then check if it got removed.
    final contextDataMap = _store[context];
    final storeData = contextDataMap?.remove(keyOrType) as ContextStoreData<T>?;
    final didRemove = storeData != null;

    if (!didRemove) return null;

    // Clean up entire context if no data.
    if (contextDataMap?.isEmpty ?? true) {
      _store.remove(context);
    }

    // Trigger the onDetach listener if it exists.
    storeData.onDetach?.call(storeData.data);
    _log(
      'Detached context data associated with context hash ${context.hashCode} and key hash ${keyOrType.hashCode}',
    );
    _log(
      'Context data map length: ${contextDataMap!.length}',
    );
    _log(
      'Store map length: ${_store.length}',
    );

    // Return the data that was removed.
    return storeData;
  }

  //
  //
  //

  ContextMap<dynamic>? clearForContext(BuildContext context) {
    return _store.remove(context);
  }

  //
  //
  //

  void _scheduleContextCheck(BuildContext context) {
    _widgetsBinding ??= WidgetsBinding.instance;
    _widgetsBinding!.addPostFrameCallback((_) {
      //_log('Post frame!');
      final contextDataMap = _store[context];
      if (contextDataMap == null) return;
      if (!context.mounted) {
        for (final key in List.of(contextDataMap.keys)) {
          _log('Detaching $key from context ${context.hashCode}');
          detach<dynamic>(context, key: key);
        }
      } else {
        // If the context is still mounted, schedule another check after
        // autoDetachDelay.
        Future.delayed(contextCheckDelay, () {
          //_log('Scheduling another context check...');
          // ignore: use_build_context_synchronously
          _scheduleContextCheck(context);
        });
      }
    });
  }

  WidgetsBinding? _widgetsBinding;

  //
  //
  //

  static bool verbose = false;

  static void _log(String message) {
    if (verbose) {
      if (kDebugMode) {
        debugPrint('[$ContextStore] $message');
      }
    }
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

typedef ContextStoreData<T> = ({T data, void Function(T data)? onDetach});
typedef ContextStoreMap<T>
    = HashMap<BuildContext, HashMap<dynamic, ContextStoreData<T>>>;
typedef ContextMap<T> = HashMap<dynamic, ContextStoreData<T>>;
