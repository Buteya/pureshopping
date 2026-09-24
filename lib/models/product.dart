import 'package:sqflite/sqflite.dart';


class Product {
  String productID;
  String productName;
  String productImage;
  double price = 0.00;
  int quantity = 1;
  String productType;
  DateTime dateOfManufacture;
  DateTime expiryDate;
  // sqflite has no boolean 0 and 1 will represent true or false
  int discountAllowed = 0;

  Product({
    required this.productID,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.productType,
    required this.dateOfManufacture,
    required this.expiryDate,
    required this.discountAllowed,
  });

  Map<String, Object?> toMap() {
    return {
      "productID": productID,
      "productName": productName,
      "productImage": productImage,
      "price": price,
      "quantity": quantity,
      "productType": productType,
      "dateOfManufacture": dateOfManufacture.toString(),
      "expiryDate": expiryDate.toString(),
      "discountAllowed": discountAllowed,
    };
  }

  @override
  String toString() {
    return 'Product{ productID:$productID, productName:$productName, productImage:$productImage, price:$price, quantity:$quantity, productType:$productType, dateOfManufacture:$dateOfManufacture, expiryDate:$expiryDate,discountAllowed:$discountAllowed}';
  }

  void insertProduct(Product product, Database database) {
    database.insert(
      'product',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  void updateProduct(Product product, Database database) {
    database.update(
      'product',
      product.toMap(),
      where: 'productID: = ?',
      whereArgs: [product.productID],
    );
  }

  void deleteProduct(Database database, int id) {
    database.delete('product', where: 'productID = ?', whereArgs: [id]);
  }

  Future<List<Product>> products(Database database) async {
    final List<Map<String, Object?>> productMaps = await database.query(
      'product',
    );
    return [
      for (final {
            "productID": prodcuctID,
            "productName": productName,
            "productImage": productImage,
            "price": price,
            "quantity": quantity,
            "productType": productType,
            "dateOfManufacture": dateOfManufacture,
            "expiryDate": expiryDate,
            "discountAllowed": discountAllowed,
          }
          in productMaps)
        Product(
          productID: productID,
          productName: productName as String,
          productImage: productImage as String,
          price: price as double,
          quantity: quantity as int,
          productType: productType as String,
          dateOfManufacture: DateTime.parse(dateOfManufacture.toString()),
          expiryDate: DateTime.parse(expiryDate.toString()),
          discountAllowed: discountAllowed as int,
        ),
    ];
  }
}
