import 'package:flutter/material.dart';
import '../utils/format_rupiah.dart';
import '../models/cart_item.dart';
import '../data/cart_notifier.dart';
import '../data/data_produk.dart';
import 'home_page.dart';

class InvoicePage extends StatelessWidget {
  final String nama;
  final String alamat;
  final String tanggal;
  final List<CartItem> items;
  final int total;

  const InvoicePage({
    super.key,
    required this.nama,
    required this.alamat,
    required this.tanggal,
    required this.items,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Invoice Pesanan'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// ===============================
          /// STATUS PESANAN
          /// ===============================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: const [
                Icon(
                  Icons.check_circle,
                  size: 48,
                  color: Colors.green,
                ),
                SizedBox(height: 8),
                Text(
                  'Pesanan Berhasil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Terima kasih telah berbelanja',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// ===============================
          /// DETAIL PENGIRIMAN
          /// ===============================
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _title(Icons.location_on, 'Detail Pengiriman'),
                const SizedBox(height: 12),
                _infoRow('Nama', nama),
                _infoRow('Alamat', alamat),
                _infoRow('Tanggal', tanggal),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// ===============================
          /// PRODUK
          /// ===============================
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _title(Icons.shopping_bag, 'Produk Dipesan'),
                const SizedBox(height: 12),
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.produk.nama,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          '${item.qty} x ${formatRupiah(item.produk.harga)}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// ===============================
          /// RINGKASAN
          /// ===============================
          _card(
            child: Column(
              children: [
                _title(Icons.receipt_long, 'Ringkasan Pembayaran'),
                const SizedBox(height: 12),
                _priceRow('Subtotal', total),
                _priceRow('Ongkir', 0),
                const Divider(height: 24),
                _priceRow(
                  'Total Pembayaran',
                  total,
                  bold: true,
                  color: Colors.blue,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          /// ===============================
          /// BUTTON
          /// ===============================
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                keranjang.clear();
                cartCount.value = 0;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomePage(),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Kembali ke Home',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ===============================
  /// HELPER UI
  /// ===============================
  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: child,
      );

  Widget _title(IconData icon, String text) => Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              child: Text(
                label,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );

  Widget _priceRow(
    String label,
    int value, {
    bool bold = false,
    Color? color,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : null,
            ),
          ),
          Text(
            formatRupiah(value),
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : null,
              color: color,
              fontSize: bold ? 18 : 14,
            ),
          ),
        ],
      );
}
