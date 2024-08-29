/*
TEST:

- What happens if we use willDispose with context within the build function of a StatefulWidget with StatefulAttachableMixin?
- What would happen if we the widget rebuilds via setState?

RESULTS:

- Works as expected.
- setState disposes previous resources, and schedules a new resource for disposal.
- onBeforeDispose is called on immediately after setState and when the widget disposes.
- This demonstates that willDispose with StatefulAttachableMixin can safely be used in the build function of a StatefulWidget.
*/

import 'package:flutter/material.dart';
import 'package:df_cleanup/df_cleanup.dart';

class Test6 extends StatefulWidget with StatefulAttachableMixin {
  const Test6({super.key});

  @override
  State<Test6> createState() => _Test6State();
}

class _Test6State extends State<Test6> {
  @override
  Widget build(BuildContext context) {
    final valueNotifer = context.willDispose(
      ValueNotifier(1),
      onBeforeDispose: (resource) {
        debugPrint('[Test6] Disposing: $resource');
      },
    );
    return Container(
      color: Colors.brown.shade200,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Test6'),
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
          FilledButton(
            onPressed: () => setState(() {}),
            child: const Text('setState'),
          ),
        ],
      ),
    );
  }
}
