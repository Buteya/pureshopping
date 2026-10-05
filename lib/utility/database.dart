import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

String sql =
    'CREATE TABLE IF NOT EXISTS users(id TEXT PRIMARY KEY, firstname TEXT, lastname TEXT, email TEXT, password TEXT, userImage TEXT)';
String sql1 =
    'CREATE TABLE IF NOT EXISTS product(productID TEXT PRIMARY KEY, productName TEXT, productImage TEXT, price REAL, quantity INTEGER, productType TEXT, dateOfManufacture TEXT, expiryDate TEXT, discountAllowed INTEGER)';
 Future<void> createDatabase() async {
  openDatabase(
    join(await getDatabasesPath(), 'pureshopping.db'),
    onCreate: (db, version) async{
      final batch = db.batch();
       batch.execute(sql);
       batch.execute(sql1);
       await batch.commit(noResult: true);
    },
    version: 1,
  );
}