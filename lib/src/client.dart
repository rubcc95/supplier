import 'package:flutter/widgets.dart';
import 'service.dart';
import 'supplier.dart';

typedef ClientBuilder<S extends Service> = Widget Function(
    ClientContext<S> value);

abstract class Client<S extends Service> extends Widget {
  factory Client(
    ClientBuilder<S> builder, {
    Key? key,
    ClientCondition<S>? condition,
  }) =>
      _ClientImpl(
        builder,
        key: key,
        condition: condition,
      );

  const Client.constructor({super.key});

  Widget build(ClientContext<S> context);
  ClientCondition<S>? get condition => null;

  @override
  Element createElement() => _ClientElement<S>(this);
}

class _ClientImpl<S extends Service> extends Client<S> {
  const _ClientImpl(
    this._build, {
    super.key,
    this.condition,
  }) : super.constructor();

  final ClientBuilder<S> _build;
  @override
  final ClientCondition<S>? condition;

  @override
  Element createElement() => _ClientElement<S>(this);

  @override
  Widget build(ClientContext<S> context) => _build(context);
}

abstract mixin class ClientContext<S> implements BuildContext {
  bool get hasService => service == null;

  S? get service;

  S get requiredService => service!;
}

class _ClientElement<S extends Service> extends ComponentElement
    implements ClientContext<S> {
  _ClientElement(super.widget);

  late bool _hasService;
  late S _service;

  Client<S> get client => super.widget as Client<S>;

  @override
  void update(covariant Widget newWidget) {
    super.update(newWidget);
    //super cause overriden rebuild listens for an already listened element
    super.rebuild();
  }

  @override
  Widget build() {
    if (_hasService) _service = read<S>()!;

    return client.build(this);
  }

  @override
  bool get hasService => _hasService;

  @override
  void rebuild({bool force = false}) { 
    final condition = client.condition;   
    _hasService = dependOnInheritedWidgetOfExactType<Supplier<S>>(aspect: condition == null
              ? null
              : (Service service) => condition(service as S)) != null;

    super.rebuild(force: force);
  }

  @override
  S get requiredService =>
      _hasService ? _service : throw ServiceNotFoundException(client);

  @override
  S? get service => _hasService ? _service : null;
}

class ServiceNotFoundException<S extends Service> implements Exception {
  const ServiceNotFoundException(this.client);

  final Client<S> client;

  @override
  String toString() => '${Supplier<S>} ancestor not found. Supply this';
}

