import 'package:df_cleanup/df_cleanup.dart';
import 'package:flutter/material.dart';

import 'test_animation.dart';
import 'pages/_index.g.dart';

void main() {
  ContextStore.instance.verbose = true;
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final pageController = PageController();

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      Test1(key: UniqueKey()),
      Test2(key: UniqueKey()),
      Test3(key: UniqueKey()),
      Test4(key: UniqueKey()),
      Test5(key: UniqueKey()),
      Test6(key: UniqueKey()),
      Test7(key: UniqueKey()),
      Test8(key: UniqueKey()),
    ];
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            const TestAnimation(),
            Expanded(
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: pageController,
                children: pages,
              ),
            ),
            OutlinedButton(
              onPressed: () {
                final nextPageIndex = ((pageController.page?.toInt() ?? 0) + 1) % pages.length;
                pageController.jumpToPage(nextPageIndex);
              },
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Next Page'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
