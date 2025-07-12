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

- What happens if we use willDispose with context within the build function of a StatefulWidget?
- What would happen if we the widget rebuilds via setState?

RESULTS:

- Works as expected.
- setState creates a new resource scheduled for disposal, but does not trigger disposal of previous resources.
- onBeforeDispose is called for each resource scheduled for disposal, about a second after the widget disposes.
- This demonstates that willDispose without StatefulAttachableMixin should not be used in the build function of a StatefulWidget,
  as it will create a new resource each time the widget rebuilds, taking memory.
*/

import 'package:flutter/material.dart';
import 'package:df_cleanup/df_cleanup.dart';

class Test5 extends StatefulWidget {
  const Test5({super.key});

  @override
  State<Test5> createState() => _Test5State();
}

class _Test5State extends State<Test5> {
  @override
  Widget build(BuildContext context) {
    final valueNotifer = context.willDispose(
      ValueNotifier(1),
      onBeforeDispose: (resource) {
        debugPrint('[Test5] Disposing: $resource');
      },
    );
    return Container(
      color: Colors.grey.shade200,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Test5'),
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
