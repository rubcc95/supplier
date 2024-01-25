import 'package:flutter/widgets.dart';

import 'subscriptor.dart';

enum ServiceStreamState { waiting, active, done, error }

class ServiceStream<T> extends ServiceSubscriptor {  
  ServiceStream(super.widget, Stream<T> stream)
      : _stream = stream;

  final Stream<T> _stream;
  ServiceStreamState _state = ServiceStreamState.waiting;
  late T _data;
  late Object _error;
  late StackTrace _stackTrace;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    addStream<T>(_stream, onData: (data) {
      _state = ServiceStreamState.active;
      _data = data;
      notify();
    }, onDone: () {
      _state = ServiceStreamState.done;
      notify();
    }, onError: (error, stackTrace) {
      _state = ServiceStreamState.error;
      _error = error;
      _stackTrace = stackTrace;
      notify();
    });
  }

  T? get data => _state == ServiceStreamState.active ? _data : null;

  T get requireData {
    assert(
        _state == ServiceStreamState.active,
        'Future has not been completed. '
        'Check for state == ${ServiceStreamState.active} or set a not null value '
        'for initialValue on constructor before using this getter.');
    return _data;
  }

  Object get error {
    assert(
        _data != null,
        'Stream has not emitted any error. '
        'Check for state == ${ServiceStreamState.error} '
        'before using this getter.');
    return _error;
  }

  StackTrace get stackTrace {
    assert(
        _data != null,
        'Stream has not emitted any StackTrace. '
        'Check for state == ${ServiceStreamState.error} '
        'before using this getter.');
    return _stackTrace;
  }

  ServiceStreamState get state => _state;
}
