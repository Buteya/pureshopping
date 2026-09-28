import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:pureshopping/utility/database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/product.dart';

enum ProductType { fruit, vegetable, processed }

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  Map<int, String> discountAllowed = {0: 'false', 1: 'true'};
  int? discount;
  String? productType;
  TextEditingController expiryDate = TextEditingController();
  TextEditingController dateOfManufacture = TextEditingController();
  TextEditingController quantity = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController name = TextEditingController();
  Product? product;
  Database? database;
  final ImagePicker _imagePicker = ImagePicker();
  XFile? pickedImage;

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('create product'),
              onTap: () {
                // Update the state of the app.
                // ...
                Navigator.pushNamed(context, '/CreateProductScreen');
              },
            ),
            ListTile(
              title: const Text('product dashboard'),
              onTap: () {
                // Update the state of the app.
                // ...
                Navigator.pushNamed(context, '/ProductDashboardScreen');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "create product",
                      style: TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SizedBox(
                      width: double.maxFinite,
                      height: 330.0,
                      child: Card(
                        color: Colors.grey,
                        child: pickedImage == null
                            ? Icon(Icons.image)
                            : Image.file(File(pickedImage!.path)),
                      ),
                    ),
                  ),
                  TextFormField(
                    readOnly: true,
                    initialValue: pickedImage?.name,
                    decoration: InputDecoration(border: InputBorder.none),
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an image';
                      }
                      if ((value.endsWith('.png') ||
                              value.endsWith('.jpg') ||
                              value.endsWith('.jpeg')) ==
                          false) {
                        return 'Please enter a valid image';
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        pickedImage = (await _imagePicker.pickImage(
                          source: ImageSource.gallery,
                        ))!;
                        setState(() {
                          pickedImage = pickedImage;
                        });
                      },
                      child: Text("upload image"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: name,
                      decoration: InputDecoration(labelText: "name"),
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        if (value.length < 3) {
                          return 'name should be more than 3 letters';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: price,
                      decoration: InputDecoration(labelText: "price"),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (value == '0.0' || value == '0') {
                          return 'Price can\'t be zero';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: quantity,
                      decoration: InputDecoration(labelText: "quantity"),
                      keyboardType: TextInputType.number,
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quantity';
                        }
                        if (value == '0') {
                          return 'Quantity can\'t be zero';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(labelText: "product type"),
                      items: ProductType.values
                          .map<DropdownMenuItem<String>>(
                            (value) => DropdownMenuItem<String>(
                              value: value.name,
                              child: Text(value.name),
                            ),
                          )
                          .toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a value';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        productType = value;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: dateOfManufacture,
                      decoration: InputDecoration(
                        labelText: "date of manufacture",
                      ),
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a date';
                        }
                        return null;
                      },
                      onTap: () async {
                        dateOfManufacture.text = (await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now(),
                        )).toString().split(" ")[0];
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: expiryDate,
                      decoration: InputDecoration(labelText: "expiry date"),
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a date';
                        }
                        return null;
                      },
                      onTap: () async {
                        expiryDate.text = (await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now(),
                        )).toString().split(" ")[0];
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        labelText: "discount allowed",
                      ),
                      items: discountAllowed.entries
                          .map<DropdownMenuItem<String>>(
                            (discount) => DropdownMenuItem<String>(
                              value: discount.value,
                              child: Text(discount.value),
                            ),
                          )
                          .toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a value';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        discount = value == "false" ? 0 : 1;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (formKey.currentState!.validate()) {
                          // If the form is valid, display a snack bar. In the real world,
                          // you'd often call a server or save the information in a database.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Processing Data...'),
                              duration: Duration(seconds: 2),
                            ),
                          );

                          product = Product(
                            productID: Uuid().v8(),
                            productName: name.text,
                            productImage: pickedImage!.path,
                            price: double.parse(price.text),
                            quantity: int.parse(quantity.text),
                            productType: productType!,
                            dateOfManufacture: DateTime.parse(
                              dateOfManufacture.text.split(" ")[0],
                            ),
                            expiryDate: DateTime.parse(
                              expiryDate.text.split(" ")[0],
                            ),
                            discountAllowed: discount!,
                          );
                          database = await openDatabase(
                            join(await getDatabasesPath(), 'pureshopping.db'),
                            onCreate: (db, version) {
                              return db.execute(sql);
                            },
                            version: 1,
                          );
                          // database!.execute('DROP TABLE product');
                          // database!.execute('CREATE TABLE product(productID TEXT PRIMARY KEY, productName TEXT, productImage TEXT, price REAL, quantity INTEGER, productType TEXT, dateOfManufacture TEXT, expiryDate TEXT, discountAllowed INTEGER)');
                          List<Map<String, Object?>> prod = await database!
                              .query(
                                'product',
                                where: 'productID = ?',
                                whereArgs: [product!.productID],
                              );
                          print('product ${product!.productID}: $prod');
                          print(
                            'is there a product with this product id ${product!.productID}${prod.firstWhere((element) => element['productID'] == product!.productID, orElse: () => {})['productID'] != product!.productID}',
                          );
                          if (prod.firstWhere(
                                (element) =>
                                    element['productID'] == product!.productID,
                                orElse: () => {},
                              )['productID'] !=
                              product!.productID) {
                            try {
                              product!.insertProduct(product!, database!);
                              print(
                                'product ${product!.productID} added successfully',
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Product with id ${product!.productID} created successfully',
                                    ),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                              if(context.mounted){
                                Navigator.pushNamed(context, '/ProductDashboardScreen');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
                          } else {
                            print(
                              'is there a product with this product id ${product!.productID}${prod.firstWhere((element) => element['productID'] == product!.productID, orElse: () => {})['productID'] != product!.productID}',
                            );
                            print(
                              'product with id ${product!.productID} : $prod',
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to create product'),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                          setState(() {
                            pickedImage = null;
                          });
                          formKey.currentState!.reset();
                        }
                      },
                      child: const Text('create'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
