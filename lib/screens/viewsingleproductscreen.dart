import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/product.dart';

class ViewSingleProductScreen extends StatefulWidget {
  const ViewSingleProductScreen({super.key});

  @override
  State<ViewSingleProductScreen> createState() =>
      _ViewSingleProductScreenState();
}

class _ViewSingleProductScreenState extends State<ViewSingleProductScreen> {
  late Future<List<Product>> products;
  @override
  void initState() {
    super.initState();
    products = fetchProducts();
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
    print('all products ${await product.products(database)}');
    return await product.products(database);
  }

  @override
  Widget build(BuildContext context) {
    String routeArgumentProductId =
        ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            final currentProduct = snapshot.data!.firstWhere(
              (product) => product.productID == routeArgumentProductId,
            );
            return Card(
              clipBehavior: Clip.hardEdge,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.file(
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 400,
                    File(currentProduct.productImage),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    label: Text('add to cart'),
                    icon: Icon(Icons.add_shopping_cart),
                  ),
                ],
              ),
            );
          }
          return Center(child: Text('no data found'));
        },
      ),
    );
  }
}
