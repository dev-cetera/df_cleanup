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

import 'dart:async';

import 'package:flutter/widgets.dart' show StatefulWidget, State;

import '/src/_index.g.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Use this instead of [State] when you want to clean up resources via
/// [willCancel], [willClose], [willDispose] or [willStop.]
abstract class CleanupState<T extends StatefulWidget> extends _CleanupState<T>
    with WillCancelMixin, WillCloseMixin, WillDisposeMixin, WillStopMixin {
  @override
  FutureOr<void> dispose() {
    super.cancel();
    super.close();
    super.dispose();
    super.stop();
  }
}

abstract class _CleanupState<T extends StatefulWidget> extends State<T> with _CleanupMixin {}

mixin _CleanupMixin implements CancelMixin, CloseMixin, DisposeMixin, StopMixin {
  @override
  FutureOr<void> cancel() {
    // Do nothing.
  }

  @override
  FutureOr<void> close() {
    // Do nothing.
  }

  @override
  FutureOr<void> dispose() {
    // Do nothing.
  }

  @override
  FutureOr<void> stop() {
    // Do nothing.
  }
}
