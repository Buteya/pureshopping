import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:pureshopping/models/cartitem.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/product.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userImage = '';
  late Future<List<Product>> productsSuper;
  late Future<List<CartItem>> cartItemsSuper;
  int counter = 0;
  String userID = '';
  final SearchController searchController = SearchController();
  @override
  void initState() {
    super.initState();
    _fetchImage();
    productsSuper = fetchProducts();
    cartItemsSuper = fetchCartItems();
  }

  Future<void> _fetchImage() async {
    SharedPreferencesWithCache prefsWithCache =
        await SharedPreferencesWithCache.create(
          cacheOptions: SharedPreferencesWithCacheOptions(
            allowList: <String>{'currentUserId', 'email', 'userImage'},
          ),
        );
    setState(() {
      userImage = prefsWithCache.getString('userImage')!;
    });
    print('current user image: $userImage');
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
      price: 0.0,
      quantity: 0,
      productType: '',
      dateOfManufacture: DateTime.now(),
      expiryDate: DateTime.now(),
      discountAllowed: 0,
    );
    print('all products: ${await product.products(database)}');
    return product.products(database);
  }

  void addToCart(String userId, String productId, BuildContext context) async {
    SharedPreferencesWithCache prefsWithCache =
        await SharedPreferencesWithCache.create(
          cacheOptions: const SharedPreferencesWithCacheOptions(
            allowList: <String>{
              'currentUserId',
              'email',
              'userImage',
              'currentCartItems',
            },
          ),
        );
    userID = (prefsWithCache.getString('currentUserId'))!;
    print('current user id: $userID');
    final db = await openDatabase(
      join(await getDatabasesPath(), 'pureshopping.db'),
      version: 1,
    );
    final cartId = Uuid().v8();
    final CartItem cartItem = CartItem(
      id: cartId,
      userId: userId,
      productId: productId,
    );

    try {
      cartItem.insertCartItem(cartItem);
      final cartItems = await cartItem.cartItems();
      setState(() {
        counter = cartItems.length;
        cartItemsSuper = fetchCartItems();
      });
      prefsWithCache.setString('currentCartItems', cartItems.length.toString());
      print('current cart Items: $cartItems');
      print('current cart items length ${cartItems.length}');
      final products = await db.query('product');
      final selectedProduct = products.firstWhere(
        (product) => product['productID'] == productId,
      );
      print('selected product $selectedProduct');
      print('selected product id: ${selectedProduct['productID']}');
      print('selected product id: ${selectedProduct['productName']}');
      var newlist = await db.query('cartItem');
      print(
        'new cart item added successfully ${newlist.firstWhere((item) => item.containsValue(cartItem.id))['id'] == cartItem.id}',
      );
      if (newlist.firstWhere((item) => item.containsValue(cartItem.id))['id'] ==
          cartItem.id) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 1),
              content: Text(
                '${selectedProduct['productName']} added successfully',
              ),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('failed to add ${selectedProduct['name']}')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    print('cartCounter is $counter');
  }

  Future<List<CartItem>> fetchCartItems() async {
    CartItem cartItem = CartItem(id: '', userId: '', productId: '');
    return await cartItem.cartItems();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: Text('pureshopping'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FutureBuilder(
              future: cartItemsSuper,
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (asyncSnapshot.hasData) {
                  return Stack(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/ViewCartScreen');
                        },
                        icon: Icon(Icons.shopping_cart),
                      ),
                      asyncSnapshot.data!.isNotEmpty
                          ? Badge.count(count: asyncSnapshot.data!.length)
                          : SizedBox(),
                    ],
                  );
                }
                return Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/ViewCartScreen');
                      },
                      icon: Icon(Icons.shopping_cart),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 48.0),
            child: userImage.isEmpty
                ? CircleAvatar()
                : CircleAvatar(
                    backgroundImage: kIsWeb
                        ? NetworkImage(userImage)
                        : FileImage(File(userImage)),
                  ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: productsSuper,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            final items = snapshot.data;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 32.0,
                  ),
                  child: SearchAnchor(
                    searchController: searchController,
                    viewOnChanged: (_) {
                      if (searchController.text.isEmpty) {
                        setState(() {
                          productsSuper = fetchProducts();
                        });
                      }
                    },
                    viewTrailing: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            productsSuper = fetchProducts();
                          });
                          searchController.clear();
                        },
                        icon: Icon(Icons.clear),
                      ),
                    ],
                    builder: (context, controller) {
                      return SearchBar(
                        controller: controller,
                        padding: WidgetStatePropertyAll<EdgeInsets>(
                          EdgeInsets.symmetric(horizontal: 16.0),
                        ),
                        onTap: () {
                          controller.openView();
                        },
                        onChanged: (_) {
                          controller.openView();
                        },
                        leading: const Icon(Icons.search),
                        hintText: 'search products...',
                      );
                    },
                    suggestionsBuilder: (context, controller) {
                      final String keyword = controller.text.toLowerCase();
                      final List<Product> filteredList = snapshot.data!
                          .where(
                            (data) => data.productName.toLowerCase().contains(
                              keyword,
                            ),
                          )
                          .toList();
                      return filteredList.map((product) {
                        return ListTile(
                          title: Text(product.productName),
                          onTap: () async {
                            setState(() {
                              productsSuper = Future.value([product]);
                            });
                            controller.closeView(product.productName);
                          },
                        );
                      }).toList();
                    },
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.filter_list),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 50,
                        maxWidth: 350,
                      ),
                      child: CarouselView.weighted(
                        flexWeights: [1, 1, 1],
                        consumeMaxWeight: false,
                        children: snapshot.data!
                            .map((prod) => prod.productType)
                            .toSet()
                            .map((product) {
                              return FilterChip.elevated(
                                label: Text(product),
                                onSelected: (_) {},
                              );
                            })
                            .toList(),
                      ),
                    ),
                  ],
                ),
                snapshot.data!.isEmpty
                    ? Center(
                        child: Column(
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 300),
                            Text('no products')
                          ],
                        ),
                      )
                    : Expanded(
                        child: GridView.builder(
                          itemCount: items!.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 4 / 3,
                                crossAxisCount: 2,
                                crossAxisSpacing: 8.0,
                                mainAxisSpacing: 8.0,
                              ),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32.0,
                                vertical: 8.0,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12.0),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/ViewSingleProductScreen',
                                    arguments: items[index].productID,
                                  );
                                },
                                child: Card(
                                  clipBehavior: Clip.hardEdge,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        child: Image.file(
                                          File(items[index].productImage),
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Text(items[index].productType),
                                      Text(items[index].productName),
                                      Text(
                                        'KSH ${items[index].price.toString()}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 16.0,
                                        ),
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            addToCart(
                                              userID,
                                              items[index].productID,
                                              context,
                                            );
                                          },
                                          label: Text('add to cart'),
                                          icon: Icon(Icons.add_shopping_cart),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            );
          }
          return Center(child: Text('no data found'));
        },
      ),
    );
  }
}
