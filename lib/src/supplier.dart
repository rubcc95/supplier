import 'package:flutter/widgets.dart';

import 'future.dart';
import 'multi.dart';
import 'notifier.dart';
import 'service.dart';
import 'stream.dart';
import 'value.dart';

typedef ServiceBuilder<T extends Service> = T Function(InheritedWidget widget);

final class Supplier<T extends Service> extends Widget
    // reason: extends same operator ==(Object) 
    // and get hashCode implementations from Widget
    // ignore: avoid_implementing_value_types
    implements InheritedWidget {
  const Supplier({
    super.key,
    required this.builder,
    Widget? child,
  }) : _maybeChild = child;

  @factory
  static Widget multi(
          {required List<Supplier> services, required Widget child}) =>
      MultiSupplier(services: services, child: child);

  @factory
  static Supplier<ServiceStream<T>> stream<T>(
          {required Stream<T> stream, required Widget child}) =>
      Supplier(
        builder: (widget) => ServiceStream(widget, stream),
        child: child,
      );

  @factory
  static Supplier<ServiceFuture<T>> future<T>(
          {required Future<T> future, required Widget child}) =>
      Supplier(
        builder: (widget) => ServiceFuture(widget, future),
        child: child,
      );

  @factory
  static Supplier<ServiceNotifier<T>> changeNotifier<T extends ChangeNotifier>(
          {required T notifier, required Widget child}) =>
      Supplier(
        builder: (widget) => ServiceNotifier(
          widget,
          notifier: notifier,
        ),
        child: child,
      );

  @factory
  static Supplier<ServiceData<T>> value<T>(T value) =>
      Supplier(builder: (widget) => ServiceData(widget, data: value));

  final Widget? _maybeChild;
  final ServiceBuilder<T> builder;

  @override
  Widget get child {
    assert(_maybeChild != null,
        '$Supplier must have a child if is not nested inside a ${Supplier.multi} constructor');
    return _maybeChild!;
  }

  @override
  Service createElement() => builder(this);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) =>
      throw StateError('Handled internally');
}