import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:collection/collection.dart';

import '../models/cartitem.dart';
import '../models/product.dart';

class ViewCartScreen extends StatefulWidget {
  const ViewCartScreen({super.key});

  @override
  State<ViewCartScreen> createState() => _ViewCartScreenState();
}

class _ViewCartScreenState extends State<ViewCartScreen> {
  late Future<List<CartItem>> cartItemsSuper;
  late Future<List<Product>> productsSuper;

  @override
  void initState() {
    super.initState();
    cartItemsSuper = fetchCartItems();
    productsSuper = fetchProducts();
  }

  Future<List<CartItem>> fetchCartItems() async {
    CartItem cartItem = CartItem(id: '', userId: '', productId: '');
    return await cartItem.cartItems();
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
    return await product.products(database);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading:IconButton(onPressed: (){Navigator.pushNamed(context, '/HomeScreen');}, icon:Icon(Icons.arrow_back_rounded) ),automaticallyImplyLeading: false,),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: FutureBuilder(
          future: Future.wait([cartItemsSuper, productsSuper]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.hasData) {
              print('snapshot cartItem: ${snapshot.data![0]}');
              print('snapshot products: ${snapshot.data![1]}');
              print('snapshot cartItem length: ${snapshot.data![0].length}');
              List<CartItem> cartItems = snapshot.data![0] as List<CartItem>;
              List<Product> products = snapshot.data![1] as List<Product>;
              Map<String, List<CartItem>> groupedCartItems = groupBy(
                cartItems,
                (cartItem) => cartItem.productId,
              );
              print(
                'cartItems grouped by productId ${groupedCartItems.keys}: $groupedCartItems',
              );
              print(
                'cartItems grouped by productId length: ${groupedCartItems.length}',
              );
              return ListView.builder(
                itemCount: groupedCartItems.length,
                itemBuilder: (context, index) {
                  Product product = products.firstWhere(
                    (product) =>
                        product.productID ==
                        groupedCartItems.keys.toList()[index],
                  );
                  print('current cart product $product');
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48.0,
                      vertical: 4.0,
                    ),
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
                        trailing: SizedBox(
                          width: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount:
                                groupedCartItems[groupedCartItems.keys
                                        .toList()[index]]!
                                    .length,
                            itemBuilder: (context, innerIndex) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      print(
                                        'snapshot cartItem: ${snapshot.data![0]}',
                                      );
                                      print(
                                        'snapshot cartItem length: ${snapshot.data![0].length}',
                                      );
                                      print(
                                        'item count same product id ${groupedCartItems[groupedCartItems.keys.toList()[index]]![innerIndex].productId}: ${groupedCartItems[groupedCartItems.keys.toList()[index]]!.length}',
                                      );
                                      try {
                                        groupedCartItems[groupedCartItems.keys
                                                .toList()[index]]![innerIndex]
                                            .deleteCartItem(
                                              groupedCartItems[groupedCartItems
                                                  .keys
                                                  .toList()[index]]![innerIndex],
                                            );
                                        setState(() {
                                          cartItemsSuper = fetchCartItems();
                                          productsSuper = fetchProducts();
                                        });
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(e.toString()),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: Text('-'),
                                  ),
                                  Text(
                                    groupedCartItems[groupedCartItems.keys
                                            .toList()[index]]!
                                        .length
                                        .toString(),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: Text('+'),
                                  ),
                                ],
                              );
                            },
                          ),
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
