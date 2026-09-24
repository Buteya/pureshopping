import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class User {
  String id;
  String firstname;
  String lastname;
  String email;
  String password;
  String userImage;

  User({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.password,
    required this.userImage,
  });

  Future<void> insertUser(User user) async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'pureshopping.db'),
      version: 1,
    );
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<User>> users() async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'pureshopping.db'),
      version: 1,
    );

    final List<Map<String, Object?>> userMaps = await db.query('users');

    return [
      for (final {
            'id': id as String,
            'firstname': firstname as String,
            'lastname': lastname as String,
            'email': email as String,
            'password': password as String,
            'userImage': userImage as String,
          }
          in userMaps)
        User(
          id: id,
          firstname: firstname,
          lastname: lastname,
          email: email,
          password: password,
          userImage: userImage,
        ),
    ];
  }

  Future<void> updateUser(User user) async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'pureshopping.db'),
      version: 1,
    );

    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteUser(User user) async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'pureshopping.db'),
      version: 1,
    );

    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'password': password,
      'userImage': userImage,
    };
  }

  @override
  String toString() {
    return 'User{id:$id,firstname:$firstname,lastname:$lastname,email:$email,password:$password,userImage:$userImage}';
  }
}
