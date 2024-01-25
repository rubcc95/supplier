import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supplier/supplier.dart';

String _toString(bool hasData) => hasData ? 'Data' : 'Empty';

void expectData({required bool hasData}) => expect(find.text(_toString(hasData)), findsOne);

class ClientT<T extends Service> extends Client<T> {
  ClientT({ClientBuilder<T>? builder, super.key})
      : _builder = builder ?? ((context) => Text(_toString(context.hasService))),
        super.constructor();

  final ClientBuilder<T> _builder;

  @override
  Widget build(ClientContext<T> context) => _builder(context);
}


class ServiceT<T> extends Service {
  ServiceT(super.widget);
}

class TestFuture extends ServiceFuture<String> {
  TestFuture(InheritedWidget widget)
      : super(
            widget,
            Future.delayed(
              const Duration(seconds: 1),
              () => 'Done',
            ));
}

void main() async {
  group(
    'Service Test',
    () {
      testWidgets(
        'Service is found through Supplier<S> => Client<S> relation',
        (t) async {
          await t.pumpWidget(
            MaterialApp(
              home: Supplier<ServiceT>(
                builder: ServiceT.new,
                child: ClientT<ServiceT>(),
              ),
            ),
          );
          expectData(hasData: true);
        },
      );

      testWidgets(
        'Service is not found through Root => Client relation',
        (t) async {
          await t.pumpWidget(
            MaterialApp(
              home: ClientT(),
            ),
          );
          expectData(hasData: false);
        },
      );

      testWidgets(
        'Service is not found through Supplier<S extends Service>'
        ' => Client<Service> relation',
        (t) async {
          await t.pumpWidget(
            MaterialApp(
              home: Supplier<ServiceT>(
                builder: ServiceT.new,
                child: ClientT(),
              ),
            ),        
          );
          expectData(hasData: false);
        },
      );
      testWidgets(
        'Service is not found through Supplier<SChild extends SParent>'
        ' => Client<SParent extends Service> relation',
        (t) async {
          await t.pumpWidget(
            MaterialApp(
              home: Supplier<ServiceT<int>>(
                builder: ServiceT<int>.new,
                child: ClientT<ServiceT<num>>(),
              ),
            ),        
          );
          expectData(hasData: false);
        },
      );

      testWidgets(
        'Service preseves Supplier assignement type',
        (t) async {
          await t.pumpWidget(
            MaterialApp(
              home: Supplier<ServiceT<num>>(
                builder: ServiceT<int>.new,
                child: ClientT<ServiceT<num>>(),
              ),
            ),        
          );
          expectData(hasData: true);
        },
      );

      testWidgets(
        "Service can only be accessed via Supplier generic type assignement",
        (t) async {
          await t.pumpWidget(
            MaterialApp(
              home: Supplier<ServiceT<num>>(
                builder: ServiceT<int>.new,
                child: ClientT<ServiceT<int>>(),
              ),
            ),        
          );
          expectData(hasData: false);
        },
      );
    },
  );
}
