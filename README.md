# DF - Cleanup

<a href="https://www.buymeacoffee.com/robmllze" target="_blank"><img align="right" src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>

Dart & Flutter Packages by DevCetra.com & contributors.

[![Pub Package](https://img.shields.io/pub/v/df_cleanup.svg)](https://pub.dev/packages/df_cleanup)
[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](https://raw.githubusercontent.com/robmllze/df_cleanup/main/LICENSE)

---

## Overview

This package offers a flexible solution for managing the lifecycle of resources in Flutter applications. Whether you're handling controllers, stream subscriptions, or any other type of disposable, cancelable, stoppable, or closable resources, it ensures that these resources are efficiently and automatically managed, minimizing the risk of memory leaks and keeping your code clean and maintainable.

## Quickstart

- Use this package as a dependency by adding it to your `pubspec.yaml` file (see here).
- This package streamlines the management of resource cancellation, closing, disposal, and stopping.
- The cleanup methods available are `willCancel`, `willClose`, `willDispose`, and `willStop`.
- Enhance your widgets by using `StatelessAttachableMixin` or `StatefulAttachableMixin` for seamless access to the cleanup methods via `BuildContext`.
- Alternatively, use `CleanupState` instead of `State` for an even simpler way to manage resources within your stateful widgets.
- Apply these [mixins](https://github.com/robmllze/df_cleanup/blob/main/lib/src/will) to any class (not just widgets) to access the cleanup methods.
- For a full feature set, please refer to the [API reference](https://pub.dev/documentation/df_cleanup/).

### Example 1 - Mixins:

`DisposeMixin` and `WillDisposeMixin` can be applied to any class to efficiently manage disposable resources. For `StatefulWidget`, you can further simplify your code by using `WillDisposeState` instead of `State`. These mixins allow you to easily mark resources like `TextEditingController` and `ValueNotifier` for automatic disposal when the widget is removed from the widget tree. This approach ensures that all resources are properly cleaned up without requiring manual intervention, streamlining resource management in your stateful widgets.

```dart
class _CounterState extends CleanupState<Counter> {
  // Define resources and schedule them to be disposed when this widget's
  // dispose method is called.
  late final _secondsRemaining = willDispose(ValueNotifier<int>(60));
  late final _tickCounter = willDispose(ValueNotifier<int>(0));
  late final _timer = willCancel(
    Timer.periodic(
      const Duration(seconds: 1),
      _onTick,
    ),
  );

  void _onTick(Timer timer) {
    if (_secondsRemaining.value > 0) {
      _secondsRemaining.value--;
      _tickCounter.value++;
    } else {
      timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Do not define methods with willDispose witin the build function, as
    // this will create an additional resource to clean up every time the
    // state is rebuilt.
    final doNotDoThis = willDispose(ValueNotifier('DO NOT DO THIS'));
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ValueListenableBuilder<int>(
          valueListenable: _secondsRemaining,
          builder: (context, value, child) {
            return Text(
              '$value seconds remaining',
              style: const TextStyle(fontSize: 24),
            );
          },
        ),
        const SizedBox(height: 20),
        ValueListenableBuilder<int>(
          valueListenable: _tickCounter,
          builder: (context, value, child) {
            return Text(
              'Ticks: $value',
              style: const TextStyle(fontSize: 24),
            );
          },
        ),
      ],
    );
  }
```

### Example 2 - BuildContext:

In some cases, you may prefer or need to manage disposable resources within a `StatelessWidget`, or you might use a `StatefulWidget` but you don't want to incorporate the mixins. The `willDispose` method can still be used effectively in these scenarios by leveraging the `BuildContext`.

```dart
class ChatBox extends StatelessWidget {
  const ChatBox({super.key});

  @override
  Widget build(BuildContext context) {
    // Define resources and schedule them to be disposed when this widget is
    // removed from the widget tree.
    final textEditingController = context.willDispose(TextEditingController());
    final focusNode = context.willDispose(FocusNode());

    return Row(
      children: [
        TextField(
          controller: textEditingController,
          focusNode: focusNode,
        ),
        ElevatedButton(
          onPressed: () {
            final text = textEditingController.text;
              print('Submitted: $text');
            textEditingController.clear();
            focusNode.requestFocus();
          },
          child: const Text('Submit!'),
        ),
      ],
    );
  }
}
```

---

## Contributing and Discussions

This is an open-source project, and we warmly welcome contributions from everyone, regardless of experience level. Whether you're a seasoned developer or just starting out, contributing to this project is a fantastic way to learn, share your knowledge, and make a meaningful impact on the community.

### Ways you can contribute:

- **Buy me a coffee:** If you'd like to support the project financially, consider [buying me a coffee](https://www.buymeacoffee.com/robmllze). Your support helps cover the costs of development and keeps the project growing.
- **Share your ideas:** Every perspective matters, and your ideas can spark innovation.
- **Report bugs:** Help us identify and fix issues to make the project more robust.
- **Suggest improvements or new features:** Your ideas can help shape the future of the project.
- **Help clarify documentation:** Good documentation is key to accessibility. You can make it easier for others to get started by improving or expanding our documentation.
- **Write articles:** Share your knowledge by writing tutorials, guides, or blog posts about your experiences with the project. It's a great way to contribute and help others learn.

No matter how you choose to contribute, your involvement is greatly appreciated and valued!

---

### Chief Maintainer:

📧 Email _Robert Mollentze_ at robmllze@gmail.com

### Dontations:

If you're enjoying this package and find it valuable, consider showing your appreciation with a small donation. Every bit helps in supporting future development. You can donate here:

https://www.buymeacoffee.com/robmllze

---

## License

This project is released under the MIT License. See [LICENSE](https://raw.githubusercontent.com/robmllze/df_cleanup/main/LICENSE) for more information.
