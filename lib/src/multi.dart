import 'package:flutter/widgets.dart';
import 'supplier.dart';

class MultiSupplier extends StatelessWidget {
  const MultiSupplier({super.key, required this.services, required this.child});

  final List<Supplier> services;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget res = child;
    for (var i = services.length; i > 0; --i)
      res = Supplier(
        builder: services[i].builder,
        child: res,
      );

    return res;
  }
}
