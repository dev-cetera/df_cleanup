/*
TEST:

- What happens if we use context.willDispose to define a ValueNotifier witin the build function of a StatelessWidget?
- Will the dispose method of the ValueNotifier be called when the widget disposes?

RESULTS:

- Works as expected.
- onBeforeDispose is called a second after the widget disposes.
- Since the widget is a StatelessWidget, the only way to track disposal is via ContextStore's polling method. This explains the delay.
*/

import 'package:flutter/material.dart';
import 'package:df_cleanup/df_cleanup.dart';

class Test1 extends StatelessWidget {
  const Test1({super.key});

  @override
  Widget build(BuildContext context) {
    final valueNotifer = context.willDispose(
      ValueNotifier(1),
      onBeforeDispose: (resource) {
        debugPrint('[Test1] Disposing: $resource');
      },
    );
    return Container(
      color: Colors.yellow.shade200,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Test1'),
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
