import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Order {
  final String id;
  final String cartItemId;
  final double total;
  final int discountAllowed;
  final double discountAmount;
  final int paid;
  final String orderedOn;

  const Order({
    required this.id,
    required this.cartItemId,
    required this.total,
    required this.discountAllowed,
    required this.discountAmount,
    required this.paid,
    required this.orderedOn,
  });

  @override
  String toString() {
    return 'Order{id:$id,cartItemId:$cartItemId,total:$total,discountAllowed:$discountAllowed,discountAmount:$discountAmount,paid:$paid,orderedOn:$orderedOn}';
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'cartItemId': cartItemId,
      'total': total,
      'discountAllowed': discountAllowed,
      'discountAmount': discountAmount,
      'paid': paid,
      'orderedOn': orderedOn,
    };
  }

  Future<void> insertOrder(Order order) async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'pureshopping.db'),
      version: 1,
    );
    await db.insert(
      'orders',
      order.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Order>> orders() async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'pureshopping.db'),
      version: 1,
    );
    final List<Map<String, Object?>> orderMaps = await db.query('orders');

    return [
      for (final {
            'id': id as String,
            'cartItemId': cartItemId as String,
            'total': total as double,
            'discountAllowed': discountAllowed as int,
            'discountAmount': discountAmount as double,
            'paid': paid as int,
            'orderedOn': orderedOn as String,
          }
          in orderMaps)
        Order(
          id: id,
          cartItemId: cartItemId,
          total: total,
          discountAllowed: discountAllowed,
          discountAmount: discountAmount,
          paid: paid,
          orderedOn: orderedOn,
        ),
    ];
  }

  Future<void> updateOrder(Order order) async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'pureshopping.db'),
      version: 1,
    );
    await db.update(
      'orders',
      order.toMap(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  Future<void> deleteOrder(Order order) async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'pureshopping.db'),
      version: 1,
    );
    await db.delete('orders', where: 'id = ?', whereArgs: [order.id]);
  }
}
