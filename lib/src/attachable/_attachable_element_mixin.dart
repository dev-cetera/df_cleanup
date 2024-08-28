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

import 'package:flutter/widgets.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

mixin AttachableElementMixin on ComponentElement {
  final _callbacks = <dynamic, CallbackRecord>{};

  var _buildCount = 0;

  var _lastAttachBuildCount = 0;

  @override
  void performRebuild() {
    _buildCount++;
    super.performRebuild();
  }

  void _addUnmountListener<T>(VoidCallback callback, [dynamic key]) {
    final keyOrType = key ?? T;
    _callbacks[keyOrType] = (buildId: _buildCount, callback: callback);
  }

  void _removeUnmountListener<T>([dynamic key]) {
    final keyOrType = key ?? T;
    _callbacks.remove(keyOrType);
  }

  void refreshAttachment<T>(
    T object,
    void Function(T object) onDetach,
    dynamic key,
  ) {
    // Check if the build count has changed
    if (_buildCount != _lastAttachBuildCount) {
      // Clear all resources associated with the previous build but not build 0,
      // where resources got defined outside of the build function.
      _clearListenersExceptInitial();
      // Update the last attach build count
      _lastAttachBuildCount = _buildCount;
    }

    _removeUnmountListener<T>(key);
    _addUnmountListener<T>(() => onDetach(object), key);
  }

  @override
  void unmount() {
    _clearListeners();
    super.unmount();
  }

  void _clearListeners() {
    for (final record in _callbacks.values) {
      record.callback();
    }
    _callbacks.clear();
  }

  void _clearListenersExceptInitial() {
    _callbacks.removeWhere((key, record) {
      final shouldRemove = record.buildId != 0;
      if (shouldRemove) {
        record.callback();
      }
      return shouldRemove;
    });
  }
}

typedef CallbackRecord = ({
  dynamic buildId,
  VoidCallback callback,
});
