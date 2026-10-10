import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

String createTableUsersSql =
    'CREATE TABLE IF NOT EXISTS users(id TEXT PRIMARY KEY, firstname TEXT, lastname TEXT, email TEXT, password TEXT, userImage TEXT, createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)';
String createTableProductSql =
    'CREATE TABLE IF NOT EXISTS product(productID TEXT PRIMARY KEY, productName TEXT, productImage TEXT, price REAL, quantity INTEGER, productType TEXT, description Text, dateOfManufacture TEXT, expiryDate TEXT, discountAllowed INTEGER, createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)';
String createTableCartItemSql =
    'CREATE TABLE IF NOT EXISTS cartItem(id TEXT PRIMARY KEY, userId TEXT, productId TEXT, createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)';
String createTableOrdersSql = 'CREATE TABLE IF NOT EXISTS orders(id TEXT PRIMARY KEY, cartItemId TEXT, total REAL, discountAllowed INTEGER, discountAmount REAL, paid INTEGER, orderedOn TEXT, createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)';
Future<void> createDatabase() async {
  openDatabase(
    join(await getDatabasesPath(), 'pureshopping.db'),
    onCreate: (db, version) async{
      final batch = db.batch();
      batch.execute('DROP TABLE IF EXISTS cartItem');
      batch.execute('DROP TABLE IF EXISTS orders');
       batch.execute(createTableUsersSql);
       batch.execute(createTableProductSql);
       batch.execute(createTableCartItemSql);
       batch.execute(createTableOrdersSql);
       await batch.commit(noResult: true);
    },
    version: 1,
  );
}