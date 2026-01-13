import 'produk.dart';

class CartItem {
  final Produk produk;
  int qty;
  bool isSelected;

  CartItem({
    required this.produk,
    this.qty = 1,
    this.isSelected = true,
  });

  int get totalHarga => produk.harga * qty;
}
