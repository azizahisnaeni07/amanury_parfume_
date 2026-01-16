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
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Invoice'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 12),
                Text(
                  'Pesanan Berhasil',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detail Pengiriman',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Nama: $nama'),
                Text('Alamat: $alamat'),
                Text('Tanggal: $tanggal'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          ...items.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${item.produk.nama} x ${item.qty}'),
                  Text(formatRupiah(item.totalHarga)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

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
              child: const Text('Kembali ke Home'),
            ),
          ),
        ],
      ),
    );
  }
}
