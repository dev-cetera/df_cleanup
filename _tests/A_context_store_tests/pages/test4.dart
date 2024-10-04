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

/*
TEST:

- What happens if we attach data to BuildContext via ContextStore, but inside initState function instead?
- What would happen if the widget rebuilds via setState?

RESULTS:

- Works as expected.
- onDetach is called and 'Hello World!' gets printed about a second after the widget disposes.
- setState does not trigger the onDetach method.
*/

import 'package:df_cleanup/df_cleanup.dart';

import 'package:flutter/material.dart';

class Test4 extends StatefulWidget {
  const Test4({super.key});

  @override
  State<Test4> createState() => _Test4State();
}

class _Test4State extends State<Test4> {
  String message = '';

  @override
  void initState() {
    message = ContextStore.of(context).attach<String>(
      'Hello World!',
      key: null,
      onDetach: (data) {
        debugPrint('[Test4] Detaching: $data');
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[Test4] Rebuilding...');

    return Container(
      color: Colors.yellow.shade200,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Test4'),
          Text(message),
          FilledButton(
            onPressed: () => setState(() {}),
            child: const Text('Call setState'),
          )
        ],
      ),
    );
  }
}
