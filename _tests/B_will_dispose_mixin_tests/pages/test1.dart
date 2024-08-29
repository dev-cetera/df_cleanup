/*
TEST:

- What happens if we use willDispose to define a ValueNotifier witin State?
- Will the dispose method of the ValueNotifier be called when the State disposes?

RESULTS:

- Works as expected.
- The expected error proves that the ValueNotifier was disposed.
*/

import 'package:df_cleanup/df_cleanup.dart';

import 'package:flutter/material.dart';

class Test1 extends StatefulWidget {
  const Test1({super.key});

  @override
  State<Test1> createState() => _Test1State();
}

class _Test1State extends State<Test1> with DisposeMixin, WillDisposeMixin {
  late final countValueNotifier = willDispose(
    ValueNotifier(0),
    onBeforeDispose: (resource) {
      debugPrint('[Test1] Disposing: $resource');
    },
  );

  @override
  void dispose() {
    super.dispose(); // ValueNotifer will be disposed of here.
    // Expecting error since we disposed of the ValueNotifier already:
    debugPrint(
        '[Test1] Expecting error "A ValueNotifier<int> was used after being disposed."...');
    try {
      countValueNotifier.dispose();
    } catch (e) {
      debugPrint('[Test1] Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red.shade200,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Test1'),
          ValueListenableBuilder(
            valueListenable: countValueNotifier,
            builder: (context, count, child) {
              return Text(count.toString());
            },
          ),
          FilledButton(
            onPressed: () => countValueNotifier.value++,
            child: const Text('Increment'),
          ),
        ],
      ),
    );
  }
}
