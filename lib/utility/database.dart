import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

String sql =
    'CREATE TABLE IF NOT EXISTS users(id TEXT PRIMARY KEY, firstname TEXT, lastname TEXT, email TEXT, password TEXT, userImage TEXT)';

 Future<void> createDatabase() async {
  openDatabase(
    join(await getDatabasesPath(), 'pureshopping.db'),
    onCreate: (db, version) {
       return db.execute(sql);
    },
    version: 1,
  );
}