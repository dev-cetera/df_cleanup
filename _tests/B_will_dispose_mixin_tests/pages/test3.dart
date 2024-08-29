/*
TEST:

- What happens if we use willDispose with an existing resource inside of a build function?
- What happens when we call setState?

RESULTS:

- Works as expected.
- valueNotifier is defined outside build. This makes it an existing resource.
- Calling setState means willDispose will be called again on an existing resource.
- An error will be thrown if calling setState since willDispose can only be called once on an existing resource.
*/

import 'package:df_cleanup/df_cleanup.dart';

import 'package:flutter/material.dart';

class Test3 extends StatefulWidget {
  const Test3({super.key});

  @override
  State<Test3> createState() => _Test3State();
}

class _Test3State extends State<Test3> with DisposeMixin, WillDisposeMixin {
  final valueNotifier = ValueNotifier(1);

  @override
  Widget build(BuildContext context) {
    final counValueNotifier = willDispose(
      valueNotifier,
      onBeforeDispose: (ValueNotifier resource) {
        debugPrint('[Test3] Disposing $build: $resource');
      },
    );
    return Container(
      color: Colors.blue.shade200,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Test3'),
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
          )
        ],
      ),
    );
  }
}
