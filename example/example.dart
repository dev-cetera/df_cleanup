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

// ignore_for_file: unused_field

import 'dart:async';

import 'package:df_cleanup/df_cleanup.dart';
import 'package:flutter/material.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
//
// EXAMPLE 1 — StatefulWidget with CleanupState.
//
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends CleanupState<Counter> {
  // Declare resources at the point of use; cleanup runs on dispose.
  late final _secondsRemaining = willDispose(ValueNotifier<int>(60));
  late final _tickCounter = willDispose(ValueNotifier<int>(0));
  late final _timer = willCancel(
    Timer.periodic(const Duration(seconds: 1), _onTick),
  );

  void _onTick(Timer timer) {
    if (_secondsRemaining.value > 0) {
      _secondsRemaining.value--;
      _tickCounter.value++;
    } else {
      timer.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    // Run an arbitrary callback on dispose.
    addCleanup(() => debugPrint('Counter cleaned up'));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ValueListenableBuilder<int>(
          valueListenable: _secondsRemaining,
          builder: (context, value, _) =>
              Text('$value seconds remaining', style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(height: 20),
        ValueListenableBuilder<int>(
          valueListenable: _tickCounter,
          builder: (context, value, _) =>
              Text('Ticks: $value', style: const TextStyle(fontSize: 24)),
        ),
      ],
    );
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
//
// EXAMPLE 2 — Smart auto-detect via willCleanup.
//
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class ChatBox extends StatefulWidget {
  const ChatBox({super.key});

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends CleanupState<ChatBox> {
  // willCleanup auto-detects dispose / close / cancel / stop on the resource.
  late final _controller = willCleanup(TextEditingController());
  late final _focusNode = willCleanup(FocusNode());
  late final _events = willCleanup(StreamController<String>.broadcast());

  // For things without one of those methods, pass an explicit onCleanup.
  late final _connection = willCleanup(
    _MyConnection(),
    onCleanup: (c) => c.shutdown(),
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: TextField(controller: _controller, focusNode: _focusNode)),
        ElevatedButton(
          onPressed: () {
            _events.add(_controller.text);
            _controller.clear();
            _focusNode.requestFocus();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

class _MyConnection {
  void shutdown() {}
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
//
// EXAMPLE 3 — Pure-Dart class using DisposeBag directly.
//
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class TickerService {
  final _bag = DisposeBag();

  late final _ticks = _bag.register(
    StreamController<int>.broadcast(),
    (c) => c.close(),
  );

  late final _timer = _bag.register(
    Timer.periodic(const Duration(seconds: 1), (_) => _ticks.add(_count++)),
    (t) => t.cancel(),
  );

  int _count = 0;

  Stream<int> get ticks => _ticks.stream;

  FutureOr<void> dispose() => _bag.dispose();
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
//
// EXAMPLE 4 — Pure-Dart class using WillCleanupMixin.
//
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class CounterBloc with WillCleanupMixin {
  late final value = willDispose(ValueNotifier<int>(0));
  late final input = willClose(StreamController<int>());

  CounterBloc() {
    addCleanup(() => debugPrint('CounterBloc cleaned up'));
    input.stream.listen((v) => value.value = v);
  }
}
