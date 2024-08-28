import 'package:df_cleanup/df_cleanup.dart';

import 'package:flutter/material.dart';

class Page3 extends StatelessWidget with StatelessAttachableMixin {
  const Page3({super.key});

  @override
  Widget build(BuildContext context) {
    final valueNotifer = context.willDispose(ValueNotifier(1));

    return Container(
      color: Colors.orange.shade200,
      width: double.infinity,
      height: double.infinity,
    );
  }
}
