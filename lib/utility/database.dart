import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

String createTableUsersSql =
    'CREATE TABLE IF NOT EXISTS users(id TEXT PRIMARY KEY, firstname TEXT, lastname TEXT, email TEXT, password TEXT, userImage TEXT)';
String createTableProductSql =
    'CREATE TABLE IF NOT EXISTS product(productID TEXT PRIMARY KEY, productName TEXT, productImage TEXT, price REAL, quantity INTEGER, productType TEXT, dateOfManufacture TEXT, expiryDate TEXT, discountAllowed INTEGER)';
String createTableCartItemSql =
    'CREATE TABLE IF NOT EXISTS cartItem(id TEXT PRIMARY KEY, userId TEXT, productId TEXT)';
Future<void> createDatabase() async {
  openDatabase(
    join(await getDatabasesPath(), 'pureshopping.db'),
    onCreate: (db, version) async{
      final batch = db.batch();
       batch.execute(createTableUsersSql);
       batch.execute(createTableProductSql);
       batch.execute(createTableCartItemSql);
       await batch.commit(noResult: true);
    },
    version: 1,
  );
}