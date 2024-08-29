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

// ignore_for_file: unused_field

import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import 'package:df_cleanup/df_cleanup.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
//
// EXAMPLE 1 - StatefulWidget with CleanupState.
//
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  _CounterState createState() => _CounterState();
}

class _CounterState extends CleanupState<Counter> {
  // Define resources and schedule them to be disposed when this widget's
  // dispose method is called.
  late final _secondsRemaining = willDispose(ValueNotifier<int>(60));
  late final _tickCounter = willDispose(ValueNotifier<int>(0));
  late final _timer = willCancel(
    Timer.periodic(
      const Duration(seconds: 1),
      _onTick,
    ),
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
  Widget build(BuildContext context) {
    context.willDispose(ValueNotifier('DO NOT DO THIS'));
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ValueListenableBuilder<int>(
          valueListenable: _secondsRemaining,
          builder: (context, value, child) {
            return Text(
              '$value seconds remaining',
              style: const TextStyle(fontSize: 24),
            );
          },
        ),
        const SizedBox(height: 20),
        ValueListenableBuilder<int>(
          valueListenable: _tickCounter,
          builder: (context, value, child) {
            return Text(
              'Ticks: $value',
              style: const TextStyle(fontSize: 24),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    // All resources will be disposed of automatically here.
    super.dispose();
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
//
// EXAMPLE 2 -  StatelessWidget and willDispose.
//
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class ChatBox extends StatelessWidget {
  const ChatBox({super.key});

  @override
  Widget build(BuildContext context) {
    // Define resources and schedule them to be disposed when this widget is
    // removed from the widget tree.
    final textEditingController = context.willDispose(TextEditingController());
    final focusNode = context.willDispose(FocusNode());

    return Row(
      children: [
        TextField(
          controller: textEditingController,
          focusNode: focusNode,
        ),
        ElevatedButton(
          onPressed: () {
            final text = textEditingController.text;
            if (kDebugMode) {
              print('Submitted: $text');
            }
            textEditingController.clear();
            focusNode.requestFocus();
          },
          child: const Text('Submit!'),
        ),
      ],
    );
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
//
// EXAMPLE 3 - StatelessAttachableMixin and willDispose.
//
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// The StatelessAttachableMixin is optional but enhances the efficiency of
/// resource management. It eliminates the need for a polling function to
/// detect when the widget is removed from the widget tree, resulting in
/// better performance.
class Form extends StatelessWidget with StatelessAttachableMixin {
  const Form({super.key});

  @override
  Widget build(BuildContext context) {
    // Define resources and schedule them to be disposed when this widget is
    // removed from the widget tree.
    final textEditingController = context.willDispose(TextEditingController());
    final scrollController = context.willDispose(ScrollController());
    final focusNode = context.willDispose(FocusNode());

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          TextField(
            controller: textEditingController,
            focusNode: focusNode,
            decoration: const InputDecoration(labelText: 'Enter your name'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final text = textEditingController.text;
              // Perform some action, like submitting the form.
              if (kDebugMode) {
                print('Name: $text');
              }
            },
            child: const Text('Submit'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Scroll to the top of the form and focus on the first field.
              scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              focusNode.requestFocus();
            },
            child: const Text('Scroll to Top'),
          ),
        ],
      ),
    );
  }
}
