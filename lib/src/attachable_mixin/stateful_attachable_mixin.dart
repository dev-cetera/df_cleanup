//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Dart/Flutter (DF) Packages by DevCetra.com & contributors. The use of this
// source code is governed by an MIT-style license described in the LICENSE
// file located in this project's root directory.
//
// See: https://opensource.org/license/mit
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import 'package:flutter/widgets.dart';

import '_attachable_element_mixin.dart';
import '_attachable_mixin.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A mixin that allows attaching data to a context within a [StatefulWidget].
mixin StatefulAttachableMixin on StatefulWidget implements AttachableMixin {
  @override
  createElement() => _StatefulElement(this);

  /// Attaches [object] to [context] via [key] and calls [onDetach] when the
  /// context is no longer valid. If [key] is `null`, the hashCode of [object]
  /// is used.
  @override
  T attach<T>(
    BuildContext context,
    T object, {
    required void Function(T object) onDetach,
    dynamic key,
  }) {
    return const AttachableMixin().attach<T>(
      context,
      object,
      onDetach: onDetach,
      key: key ?? object.hashCode,
    );
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class _StatefulElement extends StatefulElement with AttachableElementMixin {
  _StatefulElement(super.widget);
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A [StatefulWidget] with [StatefulAttachableMixin], equivalent to
/// `StatefulWidget with StatefulAttachableMixin`.
abstract class StatefulWidgetWithAttachable extends StatefulWidget
    with StatefulAttachableMixin {
  const StatefulWidgetWithAttachable({super.key});
}
