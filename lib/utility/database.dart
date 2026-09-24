import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

String sql =
    'CREATE TABLE product(productID TEXT PRIMARY KEY, productName TEXT, productImage TEXT, price REAL, quantity INTEGER, productType TEXT, dateOfManufacture TEXT, expiryDate TEXT, discountAllowed INTEGER)';

 Future<void> createDatabase() async {
  openDatabase(
    join(await getDatabasesPath(), 'pureshopping.db'),
    onCreate: (db, version) {
       return db.execute(sql);
    },
    version: 1,
  );
}