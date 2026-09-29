import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CartItem {
  final String id;
  final String userId;
  final String productId;

  const CartItem({
    required this.id,
    required this.userId,
    required this.productId,
  });

  @override
  String toString() {
    return 'CartItem{id:$id,userId:$userId,productId:$productId,}';
  }

  Map<String, Object?> toMap() {
    return {'id': id, 'userId': userId, 'productId': productId};
  }

  Future<void> insertCartItem(CartItem cartItem) async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'pureshopping.db'),
      version: 1,
    );
    await db.insert(
      'cartItem',
      cartItem.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CartItem>> cartItems() async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'pureshopping.db'),
      version: 1,
    );
    final List<Map<String, Object?>> cartItems = await db.query('cartItem');
    return [
      for (final {
            'id': id as String,
            'userId': userId as String,
            'productId': productId as String,
          }
          in cartItems)
        CartItem(id: id, userId: userId, productId: productId),
    ];
  }

  Future<void> updateCartItem(CartItem cartItem) async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'pureshopping.db'),
      version: 1,
    );
    await db.update(
      'cartItem',
      cartItem.toMap(),
      where: 'id = ?',
      whereArgs: [cartItem.id],
    );
  }

  Future<void> deleteCartItem(CartItem cartItem) async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'pureshopping.db'),
      version: 1,
    );
    await db.delete('cartItem', where: 'id = ?', whereArgs: [cartItem.id]);
  }
}
