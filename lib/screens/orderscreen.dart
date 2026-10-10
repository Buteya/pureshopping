import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/order.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late final Future<List<Order>> ordersSuper;
  late final Future<Map<String,Object?>> latestOrder;

  @override
  void initState() {
    super.initState();
    latestOrder = getLastCheckedOutOrder();
  }

  Future<List<Order>> fetchOrders() async {
    final order = Order(
      id: '',
      cartItemId: '',
      total: 0.0,
      discountAllowed: 0,
      discountAmount: 0.0,
      paid: 0,
      orderedOn: '',
    );
    return await order.orders();
  }

  Future<Map<String, Object?>> getLastCheckedOutOrder() async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'pureshopping.db'),
      version: 1,
    );

    final List<Map<String, Object?>> results = await db.query(
      'orders',
      orderBy: 'orderedOn DESC',
      limit: 1,
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: latestOrder,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (snapshot.hasData) {
            print('length of the latest order ${snapshot.data!.length}');
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Text('order summary'),
                    ListTile(
                      title: Text('items'),
                      trailing: Text(
                        jsonDecode(snapshot.data!['cartItemId'].toString()).length.toString(),
                      ),
                    ),
                    ListTile(
                      title: Text('items total'),
                      trailing: Text('KSH ${snapshot.data!['total'].toString()}'),
                    ),
                    ListTile(
                      title: Text('discount allowed'),
                      trailing: Text(
                        snapshot.data!['discountAllowed'] == 0
                            ? 'none'
                            : 'yes',
                      ),
                    ),
                    ListTile(
                      title: Text('discount amount'),
                      trailing: Text(
                        'KSH ${snapshot.data!['discountAmount'].toString()}',
                      ),
                    ),
                    ListTile(
                      title: Text('vat @ 17%'),
                      trailing: Text(
                        'KSH ${snapshot.data!['discountAmount'].toString()}',
                      ),
                    ),
                    ListTile(
                      title: Text('delivery fee'),
                      trailing: Text(
                        'KSH ${snapshot.data!['discountAmount'].toString()}',
                      ),
                    ),
                    ListTile(
                      title: Text('total'),
                      trailing: Text(
                        'KSH ${snapshot.data!['discountAmount'].toString()}',
                      ),
                    ),
                  ],
                );
              },
            );
          }
          return Center(child: Text('no data'));
        },
      ),
    );
  }
}
