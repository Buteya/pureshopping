import 'package:flutter/material.dart';

import '../models/order.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late final Future<List<Order>> ordersSuper;

  @override
  void initState() {
    super.initState();
    ordersSuper = fetchOrders();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: ordersSuper,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Text('order summary'),
                    ListTile(
                      title: Text('items'),
                      trailing: Text(
                        snapshot.data![index].cartItemId.length.toString(),
                      ),
                    ),
                    ListTile(
                      title: Text('total'),
                      trailing: Text(snapshot.data![index].total.toString()),
                    ),
                    ListTile(
                      title: Text('discount allowed'),
                      trailing: Text(
                        snapshot.data![index].discountAllowed == 0
                            ? 'none'
                            : 'yes',
                      ),
                    ),
                    ListTile(
                      title: Text('discount amount'),
                      trailing: Text(
                        snapshot.data![index].discountAmount.toString(),
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
