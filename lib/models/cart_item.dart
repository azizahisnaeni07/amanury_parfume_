import 'produk.dart';

class CartItem {
  final String? id; // UUID from Supabase
  final Produk produk;
  int qty;
  bool isSelected;
  final String variantName;

  CartItem({
    this.id,
    required this.produk,
    this.qty = 1,
    this.isSelected = true,
    required this.variantName,
  });

  int get itemPrice => produk.varianHarga[variantName] ?? produk.harga;
  int get totalHarga => itemPrice * qty;

  Map<String, dynamic> toJson() {
    return {
      'product_id': produk.id,
      'quantity': qty,
      'variant_name': variantName,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map, Produk produk) {
    return CartItem(
      id: map['id'],
      produk: produk,
      qty: map['quantity'] ?? 1,
      variantName: map['variant_name'] ?? 'All Size',
    );
  }
}
