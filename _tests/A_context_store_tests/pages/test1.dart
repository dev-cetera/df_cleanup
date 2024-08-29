/*
TEST:

- What happens if we attach data to BuildContext via ContextStore within the build function of a StatelessWidget?

RESULTS:

- Works as expected.
- onDetach is called and 'Hello World!' gets printed about a second after Page1 disposes.
*/

import 'package:df_cleanup/df_cleanup.dart';

import 'package:flutter/material.dart';

class Test1 extends StatelessWidget {
  const Test1({super.key});

  @override
  Widget build(BuildContext context) {
    final message = ContextStore.of(context).attach<String>(
      'Hello World!',
      key: null, // null implies we use data type "String" as key.
      onDetach: (data) {
        debugPrint('[Test] Detaching: $data');
      },
    );

    return Container(
      color: Colors.blue.shade200,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Text(message),
      ),
    );
  }
}
