import 'service.dart';

class ServiceData<T> extends Service {
  ServiceData(super.widget, {required this.data});

  final T data;
}