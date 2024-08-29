/*
TEST:

- What happens if we attach data to BuildContext via ContextStore, but inside the State body and not in any mehod like initState or build?
- What would happen if the widget rebuilds via setState?

RESULTS:

- Works as expected.
- onDetach is called and 'Hello World!' gets printed about a second after the widget disposes.
- setState does not trigger the onDetach method.
*/

import 'package:df_cleanup/df_cleanup.dart';

import 'package:flutter/material.dart';

class Test5 extends StatefulWidget {
  const Test5({super.key});

  @override
  State<Test5> createState() => _Test5State();
}

class _Test5State extends State<Test5> {
  late final message = ContextStore.of(context).attach<String>(
    'Hello World!',
    key: null,
    onDetach: (data) {
      debugPrint('[Test5] Detaching: $data');
    },
  );

  @override
  Widget build(BuildContext context) {
    debugPrint('[Test5] Rebuilding...');

    return Container(
      color: Colors.pink.shade200,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Test5'),
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
