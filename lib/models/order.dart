import 'cart_item.dart';

class Order {
  final String id;
  final DateTime tanggal;
  final List<CartItem> items;
  final int totalHarga;
  final String nama;
  final String alamat;

  Order({
    required this.id,
    required this.tanggal,
    required this.items,
    required this.totalHarga,
    required this.nama,
    required this.alamat,
  });
}
