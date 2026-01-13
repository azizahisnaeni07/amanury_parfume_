import 'package:flutter/material.dart';
import '../data/data_produk.dart';
import '../utils/format_rupiah.dart';
import 'checkout_page.dart';
import '../data/cart_notifier.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  /// TOTAL HANYA ITEM YANG DICENTANG
  int get totalHarga => keranjang
      .where((item) => item.isSelected)
      .fold(0, (sum, item) => sum + item.totalHarga);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Keranjang'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: keranjang.isEmpty
          ? const Center(child: Text('Keranjang masih kosong'))
          : Column(
              children: [
                /// ===============================
                /// LIST PRODUK
                /// ===============================
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: keranjang.length,
                    itemBuilder: (context, index) {
                      final item = keranjang[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// CHECKBOX
                            Checkbox(
                              value: item.isSelected,
                              onChanged: (value) {
                                setState(() {
                                  item.isSelected = value!;
                                });
                              },
                            ),

                            /// GAMBAR
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                item.produk.image,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),

                            const SizedBox(width: 12),

                            /// INFO
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.produk.nama,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatRupiah(item.produk.harga),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () {
                                          setState(() {
                                            if (item.qty > 1) item.qty--;
                                          });
                                        },
                                      ),
                                      Text(item.qty.toString()),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          setState(() {
                                            item.qty++;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            /// DELETE
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  keranjang.removeAt(index);

                                  /// 🔥 UPDATE POPUP JUGA
                                  cartCount.value = keranjang.fold(
                                    0,
                                    (sum, item) => sum + item.qty,
                                  );
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                /// ===============================
                /// TOTAL + CHECKOUT
                /// ===============================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            formatRupiah(totalHarga),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: totalHarga == 0
                              ? null
                              : () async {
                                  final selectedItems = keranjang
                                      .where((item) => item.isSelected)
                                      .toList();

                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          CheckoutPage(items: selectedItems),
                                    ),
                                  );

                                  /// ✅ HAPUS ITEM + UPDATE POPUP
                                  if (result == true) {
                                    setState(() {
                                      keranjang.removeWhere(
                                          (item) => item.isSelected);

                                      /// 🔥 INI YANG BIKIN POPUP IKUT HILANG
                                      cartCount.value = keranjang.fold(
                                        0,
                                        (sum, item) => sum + item.qty,
                                      );
                                    });
                                  }
                                },
                          child: const Text('Checkout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
