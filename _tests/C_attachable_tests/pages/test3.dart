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

/*
TEST:

- What happens if we use context.willDispose to define a ValueNotifier outside any function and inside the State?
- Will the dispose method of the ValueNotifier be called when the widget disposes?

RESULTS:

- Works as expected.
- onBeforeDispose is called a second after the widget disposes.
- Since the widget is a StatelessWidget, the only way to track disposal is via ContextStore's polling method. This explains the delay.
*/

import 'package:flutter/material.dart';
import 'package:df_cleanup/df_cleanup.dart';

class Test3 extends StatefulWidget {
  const Test3({super.key});

  @override
  State<Test3> createState() => _Test3State();
}

class _Test3State extends State<Test3> {
  late final valueNotifer = context.willDispose(
    ValueNotifier(1),
    onBeforeDispose: (resource) {
      debugPrint('[Test3] Disposing: $resource');
    },
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple.shade200,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Test3'),
          ValueListenableBuilder(
            valueListenable: valueNotifer,
            builder: (context, count, child) {
              return Text(count.toString());
            },
          ),
          FilledButton(
            onPressed: () => valueNotifer.value++,
            child: const Text('Increment'),
          ),
        ],
      ),
    );
  }
}
