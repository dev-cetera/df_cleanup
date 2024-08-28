import 'package:df_cleanup/df_cleanup.dart';
import 'package:flutter/material.dart';

import 'pages/_index.g.dart';
import 'test_animation.dart';

void main() {
  //ContextStore.instance.verbose = true;
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    final pageController = context.willDispose(PageController());
    final pages = [
      Page1(
        key: UniqueKey(),
      ),
      Page2(
        key: UniqueKey(),
      ),
      Page3(
        key: UniqueKey(),
      ),
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
                onPageChanged: (value) {
                  setState(() {});
                },
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
