/*
TEST:

- What happens if we reapeat Test5 but use a ValueNotifer instead of a String.
- Will the ValueNotifer be disposed properly?

RESULTS:

- Works as expected.
- onDetach is called and the ValueNotifier disposes about a second after the widget disposes.
- setState does not trigger the onDetach method.
*/

import 'package:df_cleanup/df_cleanup.dart';

import 'package:flutter/material.dart';

class Test6 extends StatefulWidget {
  const Test6({super.key});

  @override
  State<Test6> createState() => _Test6State();
}

class _Test6State extends State<Test6> {
  late final messageValueNotifer = ContextStore.of(context).attach(
    ValueNotifier('Hello World'),
    key: null,
    onDetach: (data) {
      debugPrint('[Test6] Disposing: $data');
      data.dispose();
    },
  );

  @override
  Widget build(BuildContext context) {
    debugPrint('[Test6] Rebuilding...');

    return Container(
      color: Colors.green.shade200,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Test6'),
          ValueListenableBuilder(
            valueListenable: messageValueNotifer,
            builder: (context, message, child) {
              return Text(message);
            },
          ),
          FilledButton(
            onPressed: () => messageValueNotifer.value += '!',
            child: const Text('!'),
          ),
          FilledButton(
            onPressed: () => setState(() {}),
            child: const Text('Call setState'),
          )
        ],
      ),
    );
  }
}
