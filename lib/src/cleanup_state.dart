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

import 'package:flutter/widgets.dart' show State, StatefulWidget;
import 'package:meta/meta.dart' show mustCallSuper;

import 'will_cleanup_mixin.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Wires [WillCleanupMixin] into [State.dispose].
///
/// Use this when you already have a [State] subclass and just want cleanup
/// behaviour mixed in:
///
/// ```dart
/// class _MyState extends State<MyWidget>
///     with WillCleanupMixin, CleanupStateMixin<MyWidget> { ... }
/// ```
///
/// For new code, prefer extending [CleanupState] directly.
///
/// `Future`s returned from `cleanup()` are intentionally not awaited because
/// [State.dispose] is synchronous. Async cleanup runs to completion in the
/// background; if you need to await it, call `cleanup()` yourself before
/// `super.dispose()`.
mixin CleanupStateMixin<W extends StatefulWidget>
    on State<W>, WillCleanupMixin {
  @override
  @mustCallSuper
  void dispose() {
    cleanup();
    super.dispose();
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A [State] with [WillCleanupMixin] pre-applied.
///
/// Replaces the boilerplate of `dispose()` calls for [Timer]s,
/// [StreamSubscription]s, [ChangeNotifier]s and friends. Declare resources
/// next to their use and let the mixin tear them down:
///
/// ```dart
/// class _CounterState extends CleanupState<CounterWidget> {
///   late final _value  = willDispose(ValueNotifier<int>(0));
///   late final _timer  = willCancel(
///     Timer.periodic(const Duration(seconds: 1), (_) => _value.value++),
///   );
///
///   @override
///   Widget build(BuildContext context) =>
///       ValueListenableBuilder(valueListenable: _value, builder: ...);
/// }
/// ```
abstract class CleanupState<W extends StatefulWidget> extends State<W>
    with WillCleanupMixin, CleanupStateMixin<W> {}
