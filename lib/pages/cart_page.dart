import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/produk.dart';
import '../models/cart_item.dart';
import '../utils/format_rupiah.dart';
import 'checkout_page.dart';
import '../data/cart_notifier.dart';
import '../utils/supabase_helper.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final supabase = Supabase.instance.client;
  List<CartItem> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    setState(() => isLoading = true);
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('cart')
          .select('*, products(*, categories(name), product_variants(*))')
          .eq('user_id', user.id);

      final List data = response as List;

      setState(() {
        cartItems = data.map<CartItem>((item) {
          final productData = item['products'];
          String kategoriNama = 'Unisex';
          final categoriesData = productData['categories'];
          if (categoriesData != null) {
            if (categoriesData is Map) {
              kategoriNama = categoriesData['name']?.toString() ?? 'Unisex';
            } else if (categoriesData is List && categoriesData.isNotEmpty) {
              kategoriNama = categoriesData[0]['name']?.toString() ?? 'Unisex';
            }
          }
          final produk = Produk.fromMap(productData, kategoriNama);
          return CartItem.fromMap(item, produk);
        }).toList();
        isLoading = false;
      });
      _updateBadge();
    } catch (e) {
      debugPrint("Error fetch cart: $e");
      setState(() => isLoading = false);
    }
  }

  void _updateBadge() {
    int total = cartItems.fold(0, (sum, item) => sum + item.qty);
    cartCount.value = total;
  }

  Future<void> updateQuantity(CartItem item, int delta) async {
    final newQty = item.qty + delta;
    if (newQty < 1) return;

    try {
      await supabase
          .from('cart')
          .update({'quantity': newQty})
          .eq('id', item.id!);

      setState(() {
        item.qty = newQty;
      });
      _updateBadge();
    } catch (e) {
      debugPrint("Error update qty: $e");
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await supabase.from('cart').delete().eq('id', id);
      setState(() {
        cartItems.removeWhere((element) => element.id == id);
      });
      _updateBadge();
    } catch (e) {
      debugPrint("Error delete item: $e");
    }
  }

  int get totalHarga => cartItems
      .where((item) => item.isSelected)
      .fold(0, (sum, item) => sum + item.totalHarga);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Keranjang Saya'), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _buildCartItem(item);
                    },
                  ),
                ),
                _buildSummary(),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Keranjang Anda kosong',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mulai Belanja'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Checkbox(
              value: item.isSelected,
              activeColor: const Color(0xFF6ADAFF),
              onChanged: (value) => setState(() => item.isSelected = value!),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey[50],
                child: item.produk.image.startsWith('assets/')
                    ? Image.asset(item.produk.image, fit: BoxFit.cover)
                    : (SupabaseHelper.getImageUrl(item.produk.image).isEmpty
                          ? const Icon(Icons.image)
                          : Image.network(
                              SupabaseHelper.getImageUrl(item.produk.image),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image),
                            )),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.produk.nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item.variantName,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatRupiah(item.itemPrice),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF6ADAFF),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => deleteItem(item.id!),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _qtyBtn(Icons.remove, () => updateQuantity(item, -1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          item.qty.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      _qtyBtn(Icons.add, () => updateQuantity(item, 1)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pembayaran',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                formatRupiah(totalHarga),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF6ADAFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: totalHarga == 0
                  ? null
                  : () async {
                      final selectedItems = cartItems
                          .where((item) => item.isSelected)
                          .toList();
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutPage(items: selectedItems),
                        ),
                      );
                      if (result == true) fetchCartItems();
                    },
              child: const Text('Checkout Sekarang'),
            ),
          ),
        ],
      ),
    );
  }
}
