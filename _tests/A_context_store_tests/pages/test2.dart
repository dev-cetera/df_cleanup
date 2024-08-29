/*
TEST:

- What happens if we attach data to BuildContext via ContextStore within the build function of a StatefulWidget?
- What would happen if we the widget rebuilds via setState?

RESULTS:

- Works as expected.
- onDetach is called and 'Hello World!' gets printed about a second after the widget disposes.
- setState does not trigger the onDetach method, instead the logs print 'Data for key hash XXX is already attached.'
*/

import 'package:df_cleanup/df_cleanup.dart';

import 'package:flutter/material.dart';

class Test2 extends StatefulWidget {
  const Test2({super.key});

  @override
  State<Test2> createState() => _Test2State();
}

class _Test2State extends State<Test2> {
  @override
  Widget build(BuildContext context) {
    debugPrint('[Test2] Rebuilding...');
    final message = ContextStore.of(context).attach<String>(
      'Hello World!',
      key: null, // null implies we use data type "String" as key.
      onDetach: (data) {
        debugPrint('[Test2] Detaching: $data');
      },
    );

    return Container(
      color: Colors.red.shade200,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Test2'),
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
