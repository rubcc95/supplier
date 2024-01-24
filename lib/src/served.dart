import 'package:flutter/widgets.dart';

import 'supplier.dart';

typedef ClientCondition<T extends Served> = bool Function(T service);

typedef _ClientConditionBase = bool Function(Served service);

class _ServedNotification<T extends Served> extends Notification {
  const _ServedNotification();

  Type get type => T;
}

abstract class Served extends InheritedElement with NotifiableElementMixin {
  Served(super.widget);

  @override
  Supplier get widget => super.widget as Supplier;

  bool _needsUpdate = false;

  Type get handledType => runtimeType;

  @override
  Widget build() {
    if (isDirty) {
      notifyClients(widget);
    }
    return super.build();
  }

  @override
  void notifyDependent(covariant Supplier oldWidget, Element dependent) {
    final condition = getDependencies(dependent) as _ClientConditionBase?;
    if (condition == null || condition(this) == true) {
      dependent.didChangeDependencies();
    }
  }

  void notify() {
    _needsUpdate = true;
    markNeedsBuild();
  }

  @override
  bool onNotification(Notification notification) {
    if (notification is _ServedNotification &&
        notification.type == runtimeType) {
      notify();
      return true;
    }
    return false;
  }

  @protected
  bool get isDirty {
    if (_needsUpdate) {
      _needsUpdate = false;
      return true;
    }
    return false;
  }
}

extension ServedContext on BuildContext {
  S read<S extends Served>() {
    final res = getElementForInheritedWidgetOfExactType<Supplier<S>>();
    if (res == null) {
      throw StateError(
          '${Supplier<S>} instance has never been included on the widget tree');
    }
    return res as S;
  }

  void listen<S extends Served>([ClientCondition<S>? condition]) =>
      dependOnInheritedWidgetOfExactType<Supplier<S>>(
          aspect: condition == null
              ? null
              : (Served service) => condition(service as S));

  void notify<S extends Served>() {
    const _ServedNotification<S> notification = _ServedNotification();
    return notification.dispatch(this);
  }
}
