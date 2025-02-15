//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Dart/Flutter (DF) Packages by dev-cetera.com & contributors. The use of this
// source code is governed by an MIT-style license described in the LICENSE
// file located in this project's root directory.
//
// See: https://opensource.org/license/mit
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

/*
TEST:

- What happens if we use willDispose with a new resource inside of a build function?
- What happens when we call setState?

RESULTS:

- Works as expected.
- Using willDispose inside the build function with a new resource will cause a new resource to be tracked for disposal each time the widget rebuilds.
- The number of resources that will be disposed of when the widget rebuilds increases with each rebuild.
- This highlights a small issue with incorrectly using willDispose inside the build function.
- However, it is uncommon for Flutter developers to define disposable resources within the build function.
*/

import 'package:df_cleanup/df_cleanup.dart';

import 'package:flutter/material.dart';

class Test2 extends StatefulWidget {
  const Test2({super.key});

  @override
  State<Test2> createState() => _Test2State();
}

class _Test2State extends State<Test2> with DisposeMixin, WillDisposeMixin {
  int builds = 0;
  @override
  Widget build(BuildContext context) {
    final build = ++builds;
    final counValueNotifier = willDispose(
      ValueNotifier(0),
      onBeforeDispose: (resource) {
        debugPrint('[Test2] Disposing $build: $resource');
      },
    );
    return Container(
      color: Colors.green.shade200,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Test2'),
          ValueListenableBuilder(
            valueListenable: counValueNotifier,
            builder: (context, count, child) {
              return Text(count.toString());
            },
          ),
          FilledButton(
            onPressed: () => counValueNotifier.value++,
            child: const Text('Increment'),
          ),
          FilledButton(
            onPressed: () => setState(() {}),
            child: const Text('setState'),
          ),
        ],
      ),
    );
  }
}
