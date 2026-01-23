import 'cart_item.dart';

class Order {
  final String id;
  final String userId;
  final DateTime tanggal;
  final List<CartItem> items;
  final int totalHarga;
  final String nama;
  final String alamat;
  final String status;

  Order({
    required this.id,
    required this.userId,
    required this.tanggal,
    required this.items,
    required this.totalHarga,
    required this.nama,
    required this.alamat,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'total_price': totalHarga,
      'customer_name': nama,
      'address': alamat,
      'status': status,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map, List<CartItem> items) {
    return Order(
      id: map['id'],
      userId: map['user_id'],
      tanggal: DateTime.parse(map['created_at']),
      items: items,
      totalHarga: map['total_price'],
      nama: map['customer_name'],
      alamat: map['address'],
      status: map['status'],
    );
  }
}
