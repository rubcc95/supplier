import 'package:flutter/widgets.dart';

import 'served.dart';
import 'supplier.dart';

mixin ServedProxyMixin<S extends Served> on Served {
  bool _needsUpdate = false;

  bool proxyUpdateShouldNotify(S? value) => true;

  @override
  void update(covariant Supplier newWidget) {
    _needsUpdate = true;
    super.update(newWidget);
  }

  @override
  bool updateShouldNotify() {
    if (super.updateShouldNotify() || _needsUpdate) {
      _needsUpdate = false;
      return true;
    }
    return false;
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    listen<S>(proxyUpdateShouldNotify);
  }
}

class ServedProxy<S extends Served> = Served with ServedProxyMixin<S>;
