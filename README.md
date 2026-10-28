[![pub](https://img.shields.io/pub/v/df_cleanup.svg)](https://pub.dev/packages/df_cleanup)
[![tag](https://img.shields.io/badge/Tag-v1.1.0-purple?logo=github)](https://github.com/dev-cetera/df_cleanup/tree/v1.1.0)
[![instagram](https://img.shields.io/badge/Instagram-E4405F?logo=instagram&logoColor=white)](https://www.instagram.com/dev_cetera/)
[![license](https://img.shields.io/badge/License-MIT-blue.svg)](https://raw.githubusercontent.com/dev-cetera/df_cleanup/main/LICENSE)

---

<!-- BEGIN _README_CONTENT -->

## Overview

This package offers a flexible solution for managing the cleanup of resources in Flutter. Whether you're handling controllers, stream subscriptions, or any other type of disposable, cancelable, stoppable, or closable resources, it ensures that these resources are efficiently and automatically managed, minimizing the risk of memory leaks and keeping your code clean and maintainable.

## Quickstart

- This package streamlines the management of resource cancellation, closing, disposal, and stopping.
- The cleanup methods available are `willCancel`, `willClose`, `willDispose`, and `willStop`.
- Enhance your widgets by using `StatelessAttachableMixin` or `StatefulAttachableMixin` for seamless access to the cleanup methods via `BuildContext`.
- Alternatively, use `CleanupState` instead of `State` for an even simpler way to manage resources within your stateful widgets.
- Apply these [mixins](https://github.com/dev-cetera/df_cleanup/blob/main/lib/src/will) to any class (not just widgets) to access the cleanup methods.

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

<!-- END _README_CONTENT -->

---

🔍 For more information, refer to the [API reference](https://pub.dev/documentation/df_cleanup/).

---

## 💬 Contributing and Discussions

This is an open-source project, and we warmly welcome contributions from everyone, regardless of experience level. Whether you're a seasoned developer or just starting out, contributing to this project is a fantastic way to learn, share your knowledge, and make a meaningful impact on the community.

### ☝️ Ways you can contribute

- **Raise a ticket:** Open an issue on the [GitHub repository](https://github.com/dev-cetera/df_cleanup/issues) for questions, bugs and feature requests.
- **Get in touch:** Email [hello@robertsolves.com.au](mailto:hello@robertsolves.com.au) if you would like to contribute or collaborate.
- **Share your ideas:** Every perspective matters, and your ideas can spark innovation.
- **Help others:** Engage with other users by offering advice, solutions, or troubleshooting assistance.
- **Report bugs:** Help us identify and fix issues to make the project more robust.
- **Suggest improvements or new features:** Your ideas can help shape the future of the project.
- **Help clarify documentation:** Good documentation is key to accessibility. You can make it easier for others to get started by improving or expanding our documentation.
- **Write articles:** Share your knowledge by writing tutorials, guides, or blog posts about your experiences with the project. It's a great way to contribute and help others learn.

No matter how you choose to contribute, your involvement is greatly appreciated and valued!

## 👤 Author & Contact

- Website: [robertsolves.com.au](https://robertsolves.com.au)
- Organization: [dev-cetera.com](https://dev-cetera.com)
- Email: [robert@dev-cetera.com](mailto:robert@dev-cetera.com) or [hello@robertsolves.com.au](mailto:hello@robertsolves.com.au)

## LICENSE

This project is released under the [MIT License](https://raw.githubusercontent.com/dev-cetera/df_cleanup/main/LICENSE). See [LICENSE](https://raw.githubusercontent.com/dev-cetera/df_cleanup/main/LICENSE) for more information.
