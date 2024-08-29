/*
TEST:



RESULTS:


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
