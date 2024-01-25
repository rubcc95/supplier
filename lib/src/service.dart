import 'package:flutter/widgets.dart';

import 'supplier.dart';

typedef ClientCondition<S extends Service> = bool Function(S service);

abstract class Service extends InheritedElement with NotifiableElementMixin {
  Service(super.widget);

  @override
  Supplier get widget => super.widget as Supplier;

  bool _needsUpdate = false;

  Type get handledType => runtimeType;

  @override
  Widget build() {
    if (isDirty) notifyClients(widget);

    return super.build();
  }

  @override
  void notifyDependent(covariant Supplier oldWidget, Element dependent) {
    final condition = getDependencies(dependent) as bool Function(Service)?;
    if (condition == null || condition(this) == true)
      dependent.didChangeDependencies();
  }

  void notify() {
    _needsUpdate = true;
    markNeedsBuild();
  }

  @override
  bool onNotification(Notification notification) {
    if (notification is _ServiceNotification &&
        notification.type == runtimeType) {
      notify();
      return true;
    }
    return false;
  }

  @protected
  bool get isDirty {
    if (!_needsUpdate) return false;

    _needsUpdate = false;
    return true;
  }
}

extension ServiceContext on BuildContext {
  S? read<S extends Service>() =>
      getElementForInheritedWidgetOfExactType<Supplier<S>>() as S?;

  Supplier<S>? listen<S extends Service>([ClientCondition<S>? condition]) =>
      dependOnInheritedWidgetOfExactType<Supplier<S>>(
          aspect: condition == null
              ? null
              : (Service service) => condition(service as S));

  void notify<S extends Service>() {
    const _ServiceNotification<S> notification = _ServiceNotification();
    return notification.dispatch(this);
  }
}

class _ServiceNotification<S extends Service> extends Notification {
  const _ServiceNotification();

  Type get type => S;
}

class MyWidget extends Widget{
  const MyWidget({super.key});

  @override
  MyElement createElement() => MyElement(this);
  
}
class _Printer{
  int _count = 0;
  String get indent => List.filled(_count, '-').join();
  void add(String data){
    print('$indent$data start');
    _count++;
  }
  void set(String data){
    print('$indent$data');
  }
  void remove(String data){
    print('$indent$data remove');
    _count--;
  }
}
class MyElement extends ComponentElement{
  MyElement(super.widget);
  final _p = _Printer();
  @override
  void unmount() {
        _p.add('unmount');
    super.unmount();
    _p.remove('unmount');
  }

  @override
  void mount(Element? parent, Object? newSlot) {   
    _p.add('mount');
    super.mount(parent, newSlot);
    _p.remove('mount');
  }

  @override
  void rebuild({bool force = false}) {
    _p.add('rebuild');
    super.rebuild(force: force);
    _p.remove('rebuild');
  }

  @override
  void update(covariant Widget newWidget) {
    _p.set('update');
    super.update(newWidget);
    _p.remove('update');
  }

  @override
  Element? updateChild(Element? child, Widget? newWidget, Object? newSlot) {
    _p.set('updateChild');
    final res = super.updateChild(child, newWidget, newSlot);
    _p.remove('updateChild');
    return res;
  }

  @override
  Widget build() {
    _p.set('build');
    return Container();
  }
}