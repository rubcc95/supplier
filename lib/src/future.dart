import 'package:flutter/widgets.dart';
import 'subscriptor.dart';

enum ServiceFutureState { waiting, done, error }
//make my desired intellicode!
class ServiceFuture<T> extends ServiceSubscriptor {  
  ServiceFuture(super.widget, Future<T> future)
      : _future = future;

  final Future<T> _future;
  ServiceFutureState _state = ServiceFutureState.waiting;  
  late T _data;
  late Object _error;
  late StackTrace _stackTrace;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    addFuture<T>(_future, onData: (data) {
      _state = ServiceFutureState.done;
      _data = data;
      notify();
    }, onError: (error, stackTrace) {
      _state = ServiceFutureState.error;
      _error = error;
      _stackTrace = stackTrace;
      notify();
    });
  }

  T? get data => _state == ServiceFutureState.done ? _data : null;

  T get requireData {
    assert(
        _state == ServiceFutureState.done,
        'Future has not been completed. '
        'Check for state == ${ServiceFutureState.done} or set a not null value '
        'for initialValue on constructor before using this getter.');
    return _data;
  }

  Object get error {
    assert(
        _state == ServiceFutureState.error,
        'Future has not emitted any error. '
        'Check for state == ${ServiceFutureState.error} '
        'before using this getter.');
    return _error;
  }

  StackTrace get stackTrace {
    assert(
        _state == ServiceFutureState.error,
        'Future has not emitted any StackTrace. '
        'Check for state == ${ServiceFutureState.error} '
        'before using this getter.');
    return _stackTrace;
  }

  ServiceFutureState get state => _state;
}