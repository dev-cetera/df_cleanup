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

import 'package:df_cleanup/df_cleanup.dart';
import 'package:flutter/material.dart';

import 'pages/_index.g.dart';
import 'test_animation.dart';

void main() {
  ContextStore.verbose = true;
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
    const pages = [Test1(), Test2(), Test3(), Test4(), Test5(), Test6()];
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
