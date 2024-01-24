import 'package:flutter/widgets.dart';

import 'multi.dart';
import 'notifier.dart';
import 'future.dart';
import 'value.dart';
import 'served.dart';
import 'stream.dart';

typedef CreateServed<T extends Served> = T Function(InheritedWidget widget);

final class Supplier<T extends Served> extends Widget
    implements InheritedWidget {
  const Supplier({
    super.key,
    required this.init,
    Widget? child,
  }) : _maybeChild = child;

  @factory
  static Widget multi(
          {required List<Supplier> services, required Widget child}) =>
      MultiSupplier(services: services, child: child);

  @factory
  static Supplier<ServedStream<T>> stream<T>(
          {required Stream<T> stream,
          T? initialValue,
          required Widget child}) =>
      Supplier(
        init: (widget) =>
            ServedStream(widget, stream: stream, initialValue: initialValue),
        child: child,
      );

  @factory
  static Supplier<ServedFuture<T>> future<T>(
          {required Future<T> future,
          T? initialValue,
          required Widget child}) =>
      Supplier(
        init: (widget) =>
            ServedFuture(widget, future: future, initialValue: initialValue),
        child: child,
      );

  @factory
  static Supplier<ServedNotifier<T>> changeNotifier<T extends ChangeNotifier>(
          {required T notifier, required Widget child}) =>
      Supplier(
        init: (widget) => ServedNotifier(
          widget,
          notifier: notifier,
        ),
        child: child,
      );

  @factory
  static Supplier<ServedValue<T>> value<T>(T value) =>
      Supplier(init: (widget) => ServedValue(widget, value: value));

  final Widget? _maybeChild;
  final CreateServed<T> init;

  @override
  Widget get child {
    assert(_maybeChild != null,
        '$Supplier must have a child if is not nested inside a ${Supplier.multi} constructor');
    return _maybeChild!;
  }

  @override
  Served createElement() => init(this);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) =>
      throw StateError('Handled internally');
}
