import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:supplier/supplier.dart';

class ServedExample extends Served {
  ServedExample(super.widget);

  String get exampleStr => 'Example';

  int get extampleInt => 777;
}

void main() async {
  testWidgets('description', (t) async {
    await t.pumpWidget(MaterialApp(
      home: Supplier.future<String>(
        future: Future.value('Yolo'),
        initialValue: 'None',
        child: Client<ServedFuture<String>>((served) => Text(served!.value)),
      ),
    ));
    await t.pump(const Duration(seconds: 10));
    expect(find.text('None'), findsOneWidget);
  });
}
