import 'package:flutter/material.dart';
import '../models/produk.dart';
import '../models/cart_item.dart';
import '../data/data_produk.dart';
import '../utils/format_rupiah.dart';
import '../data/cart_notifier.dart';
import 'cart_page.dart';

class DetailProdukPage extends StatelessWidget {
  final Produk produk;

  const DetailProdukPage({
    super.key,
    required this.produk,
  });

  /// ===============================
  /// TAMBAH KE KERANJANG
  /// ===============================
  void tambahKeKeranjang(BuildContext context) {
    final index = keranjang.indexWhere(
      (item) => item.produk.nama == produk.nama,
    );

    if (index >= 0) {
      keranjang[index].qty++;
    } else {
      keranjang.add(CartItem(produk: produk));
    }

    cartCount.value = keranjang.fold(
      0,
      (sum, item) => sum + item.qty,
    );
  }

  /// ===============================
  /// BELI SEKARANG
  /// ===============================
  void beliSekarang(BuildContext context) {
    tambahKeKeranjang(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CartPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// ===============================
      /// APPBAR
      /// ===============================
      appBar: AppBar(
        title: Text(produk.nama),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      /// ===============================
      /// BODY
      /// ===============================
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ===============================
            /// GAMBAR PRODUK
            /// ===============================
            Container(
              width: double.infinity,
              height: 340,
              color: const Color(0xFFF3F4F6),
              child: Center(
                child: Image.asset(
                  produk.image,
                  fit: BoxFit.contain,
                  height: 280,
                  errorBuilder: (_, __, ___) {
                    return const Icon(
                      Icons.image_not_supported,
                      size: 100,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
            ),

            /// ===============================
            /// DETAIL PRODUK
            /// ===============================
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// NAMA PRODUK
                  Text(
                    produk.nama,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// DESKRIPSI LENGKAP (PANJANG)
                  Text(
                    produk.deskripsiLengkap,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.8,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// HARGA
                  Text(
                    formatRupiah(produk.harga),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// ===============================
                  /// BUTTON AKSI
                  /// ===============================
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            tambahKeKeranjang(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Produk ditambahkan ke keranjang',
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            side: const BorderSide(
                              color: Color(0xFF2563EB),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Tambah ke Keranjang',
                            style: TextStyle(
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => beliSekarang(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Beli Sekarang',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
