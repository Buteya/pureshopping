import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/cartitem.dart';
import '../models/product.dart';

class ViewCartScreen extends StatefulWidget {
  const ViewCartScreen({super.key});

  @override
  State<ViewCartScreen> createState() => _ViewCartScreenState();
}

class _ViewCartScreenState extends State<ViewCartScreen> {
  late Future<List<CartItem>> cartItems;
  late Future<List<Product>> products;

  @override
  void initState() {
    super.initState();
    cartItems = fetchCartItems();
    products = fetchProducts();
  }

  Future<List<CartItem>> fetchCartItems() async {
    CartItem cartItem = CartItem(id: '', userId: '', productId: '');
    return cartItem.cartItems();
  }

  Future<List<Product>> fetchProducts() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'pureshopping.db'),
      version: 1,
    );
    Product product = Product(
      productID: '',
      productName: '',
      productImage: '',
      price: 0,
      quantity: 0,
      productType: '',
      dateOfManufacture: DateTime.now(),
      expiryDate: DateTime.now(),
      discountAllowed: 0,
    );
    print('all products: ${await product.products(database)}');
    return await product.products(database);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: FutureBuilder(
          future: Future.wait([cartItems, products]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.hasData) {
              final List<CartItem> items = snapshot.data![0] as List<CartItem>;
              print('snapshot data: ${snapshot.data![0]}');
              print('all products: ${snapshot.data![1]}');
              final List<Product> products = snapshot.data![1] as List<Product>;
              print('list products $products');
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final product = products.firstWhere(
                    (product) => product.productID == items[index].productId,
                  );
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48.0,vertical: 4.0),
                    child: Card(
                      child: ListTile(
                        leading: Text((index + 1).toString()),
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Card(
                              clipBehavior: Clip.hardEdge,
                              child: Image.file(
                                height: 50,
                                width: 50,
                                File(product.productImage),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(product.productName),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(onPressed: () {}, child: Text('-')),
                            Text('1'),
                            TextButton(onPressed: () {}, child: Text('+')),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return Center(child: Text('no data found'));
          },
        ),
      ),
    );
  }
}
