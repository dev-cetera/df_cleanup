## Overview

This package offers a flexible solution for managing the cleanup of resources in Flutter. Whether you're handling controllers, stream subscriptions, or any other type of disposable, cancelable, stoppable, or closable resources, it ensures that these resources are efficiently and automatically managed, minimizing the risk of memory leaks and keeping your code clean and maintainable.

## Quickstart

- Use this package as a dependency by adding it to your `pubspec.yaml` file (see here).
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