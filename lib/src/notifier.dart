import 'package:flutter/widgets.dart';
import 'subscriptor.dart';

class ServiceNotifier<N extends ChangeNotifier> extends ServiceSubscriptor {
  ServiceNotifier(super.widget, {required this.notifier});

  final N notifier;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    addChangeNotifier(notifier, onChange: notify);
  }
}