import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

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
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/HomeScreen');
          },
          icon: Icon(Icons.arrow_back_rounded),
        ),
        automaticallyImplyLeading: false,
      ),
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
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 48, right: 112.0),
                    child: ListTile(
                      leading: Text('no'),
                      title: Text('item'),
                      trailing: Text('quantity'),
                    ),
                  ),
                  groupedCartItems.isEmpty
                      ? Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: 300),
                              child: Image.asset('assets/new empty cart.png'),
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: groupedCartItems.length,
                            itemBuilder: (context, index) {
                              Product product = products.firstWhere(
                                (product) =>
                                    product.productID ==
                                    groupedCartItems.keys.toList()[index],
                              );
                              print('current cart product $product');
                              return Dismissible(
                                key: Key(index.toString()),
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerLeft,
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  return await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('remove product'),
                                        content: const Text(
                                          'are you sure you want to remove this product?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            child: Text('cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                            child: Text('confirm'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                onDismissed: (direction) async {
                                  try {
                                    final db = await openDatabase(
                                      join(
                                        await getDatabasesPath(),
                                        'pureshopping.db',
                                      ),
                                      version: 1,
                                    );
                                    final List<String> ids =
                                        groupedCartItems[groupedCartItems.keys
                                                .toList()[index]]!
                                            .map((cartItem) => cartItem.id)
                                            .toList();
                                    print('cart items to be deleted $ids');
                                    String placeholders = List.filled(
                                      ids.length,
                                      '?',
                                    ).join(',');
                                    await db.rawDelete(
                                      'DELETE FROM cartItem WHERE id IN ($placeholders)',
                                      ids,
                                    );
                                    print(
                                      'is cart item still available in cart? ${groupedCartItems.keys.toList().contains(ids[0])}',
                                    );
                                    if (!groupedCartItems.keys
                                        .toList()
                                        .contains(ids[0])) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            duration: Duration(seconds: 2),
                                            content: Text(
                                              'product deleted successfully',
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'failed to delete product',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                    setState(() {
                                      cartItemsSuper = fetchCartItems();
                                    });
                                    print(
                                      'cartItems grouped by productId ${groupedCartItems.keys}: $groupedCartItems',
                                    );
                                    print(
                                      'cartItems grouped by productId length: ${groupedCartItems.length}',
                                    );
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(e.toString())),
                                      );
                                    }
                                  }
                                },
                                child: Padding(
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
                                            padding: const EdgeInsets.only(
                                              left: 8.0,
                                            ),
                                            child: Text(product.productName),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 160.0,
                                            ),
                                            child: Text('KSH ${product.price}'),
                                          ),
                                        ],
                                      ),
                                      trailing: SizedBox(
                                        width: 150,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount:
                                              groupedCartItems[groupedCartItems
                                                      .keys
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
                                                      if (groupedCartItems[groupedCartItems
                                                                  .keys
                                                                  .toList()[index]]!
                                                              .length >
                                                          1) {
                                                        groupedCartItems[groupedCartItems
                                                                .keys
                                                                .toList()[index]]![innerIndex]
                                                            .deleteCartItem(
                                                              groupedCartItems[groupedCartItems
                                                                  .keys
                                                                  .toList()[index]]![innerIndex],
                                                            );
                                                        print(
                                                          'item with productId ${groupedCartItems[groupedCartItems.keys.toList()[index]]![innerIndex].productId} deleted successfully',
                                                        );
                                                        setState(() {
                                                          cartItemsSuper =
                                                              fetchCartItems();
                                                          productsSuper =
                                                              fetchProducts();
                                                        });
                                                      } else {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                'remove product',
                                                              ),
                                                              content: const Text(
                                                                'are you sure you want to remove this product?',
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () {
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop();
                                                                  },
                                                                  child: Text(
                                                                    'cancel',
                                                                  ),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () {
                                                                    groupedCartItems[groupedCartItems
                                                                            .keys
                                                                            .toList()[index]]![innerIndex]
                                                                        .deleteCartItem(
                                                                          groupedCartItems[groupedCartItems
                                                                              .keys
                                                                              .toList()[index]]![innerIndex],
                                                                        );
                                                                    print(
                                                                      'item with productId ${groupedCartItems[groupedCartItems.keys.toList()[index]]![innerIndex].productId} deleted successfully',
                                                                    );
                                                                    setState(() {
                                                                      cartItemsSuper =
                                                                          fetchCartItems();
                                                                      productsSuper =
                                                                          fetchProducts();
                                                                    });
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop();
                                                                  },
                                                                  child: Text(
                                                                    'confirm',
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      }
                                                    } catch (e) {
                                                      if (context.mounted) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              e.toString(),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  },
                                                  child: Text('-'),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: Text(
                                                    groupedCartItems[groupedCartItems
                                                            .keys
                                                            .toList()[index]]!
                                                        .length
                                                        .toString(),
                                                  ),
                                                ),
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
                                                      print(
                                                        'item to add ${groupedCartItems[groupedCartItems.keys.toList()[index]]![innerIndex]}',
                                                      );
                                                      CartItem
                                                      addCartItem = CartItem(
                                                        id: Uuid().v8(),
                                                        userId:
                                                            groupedCartItems[groupedCartItems
                                                                    .keys
                                                                    .toList()[index]]![innerIndex]
                                                                .userId,
                                                        productId:
                                                            groupedCartItems[groupedCartItems
                                                                    .keys
                                                                    .toList()[index]]![innerIndex]
                                                                .productId,
                                                      );
                                                      await groupedCartItems[groupedCartItems
                                                              .keys
                                                              .toList()[index]]![innerIndex]
                                                          .insertCartItem(
                                                            addCartItem,
                                                          );
                                                      print(
                                                        'item with productId ${groupedCartItems[groupedCartItems.keys.toList()[index]]![innerIndex].productId} added successfully',
                                                      );
                                                      setState(() {
                                                        cartItemsSuper =
                                                            fetchCartItems();
                                                        productsSuper =
                                                            fetchProducts();
                                                      });
                                                    } catch (e) {
                                                      if (context.mounted) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              e.toString(),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  },
                                                  child: Text('+'),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                  SizedBox(
                    width: double.infinity,
                    height: 120,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 128.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Material(
                                  shape: StadiumBorder(),
                                  elevation: 2.0,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                      horizontal: 16.0,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('total items'),
                                        Text(cartItems.length.toString()),
                                      ],
                                    ),
                                  ),
                                ),
                                Material(
                                  shape: StadiumBorder(),
                                  elevation: 4.0,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                      horizontal: 16.0,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('price'),
                                        Text(
                                          'KSH ${List.generate((products.where((prod) => cartItems.map((cart) => cart.productId).contains(prod.productID)).toList().map((item) => item.price).toList()).length, (i) => (products.where((prod) => cartItems.map((cart) => cart.productId).contains(prod.productID)).toList().map((item) => item.price).toList())[i] * groupedCartItems.values.map((list) => list.length).toList()[i]).fold(0.00, (initialValue, sum) => initialValue + sum)}',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (cartItems.isNotEmpty) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('remove cart'),
                                            content: const Text(
                                              'are you sure you want to remove all the products?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  try {
                                                    final db = await openDatabase(
                                                      join(
                                                        await getDatabasesPath(),
                                                        'pureshopping.db',
                                                      ),
                                                      version: 1,
                                                    );
                                                    if (cartItems.isNotEmpty) {
                                                      await db.delete('cartItem');
                                                      setState(() {
                                                        cartItemsSuper =
                                                            fetchCartItems();
                                                      });
                                                      if (context.mounted) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            duration: Duration(
                                                              seconds: 1,
                                                            ),
                                                            content: Text(
                                                              'all products have been removed',
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    } else {
                                                      if (context.mounted) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            duration: Duration(
                                                              seconds: 1,
                                                            ),
                                                            content: Text(
                                                              'no products to remove',
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    }

                                                    if (context.mounted) {
                                                      Navigator.of(context).pop();
                                                    }
                                                  } catch (e) {
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            e.toString(),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                                child: Text('confirm'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'no products to be removed',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: Text('delete cart'),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (cartItems.isEmpty) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            duration: Duration(seconds: 1),
                                            content: Text(
                                              'no items to checkout ',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: Text('checkout ${cartItems.length}'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return Center(child: Text('no data found'));
          },
        ),
      ),
    );
  }
}
