import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../utils/format_rupiah.dart';
import 'invoice_page.dart';
import '../models/order.dart';
import '../data/order_data.dart';
import '../data/cart_notifier.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> items;

  const CheckoutPage({
    super.key,
    required this.items,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final namaC = TextEditingController();
  final alamatC = TextEditingController();

  int get totalHarga =>
      widget.items.fold(0, (sum, item) => sum + item.totalHarga);

  String tanggalHariIni() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  /// ===============================
  ///  PERBAIKAN UTAMA ADA DI SINI
  /// ===============================
  Future<void> lanjutBayar() async {
    if (namaC.text.isEmpty || alamatC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama & alamat wajib diisi')),
      );
      return;
    }

    ///  SIMPAN KE RIWAYAT PESANAN
    orderHistory.add(
      Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tanggal: DateTime.now(),
        items: List.from(widget.items),
        totalHarga: totalHarga,
        nama: namaC.text,
        alamat: alamatC.text,
      ),
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InvoicePage(
          nama: namaC.text,
          alamat: alamatC.text,
          tanggal: tanggalHariIni(),
          items: widget.items,
          total: totalHarga,
        ),
      ),
    );

    ///  JIKA INVOICE SELESAI
    if (result == true) {
      widget.items.clear();
      cartCount.value = 0;

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// ALAMAT
          Container(
            padding: const EdgeInsets.all(16),
            decoration: box(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                rowTitle(Icons.location_on, 'Alamat Pengiriman'),
                const SizedBox(height: 12),
                TextField(
                  controller: namaC,
                  decoration: input('Nama Penerima'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: alamatC,
                  maxLines: 3,
                  decoration: input('Alamat Lengkap'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// PRODUK
          Container(
            padding: const EdgeInsets.all(16),
            decoration: box(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                rowTitle(Icons.shopping_bag, 'Produk Dipesan'),
                const SizedBox(height: 12),
                ...widget.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(item.produk.nama,
                                  style: const TextStyle(
                                      fontWeight:
                                          FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                '${item.qty} x ${formatRupiah(item.produk.harga)}',
                                style: const TextStyle(
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          formatRupiah(item.totalHarga),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// RINGKASAN
          Container(
            padding: const EdgeInsets.all(16),
            decoration: box(),
            child: Column(
              children: [
                rowHarga('Subtotal', totalHarga),
                const SizedBox(height: 8),
                rowHarga('Ongkir', 0),
                const Divider(height: 24),
                rowHarga('Total Pembayaran', totalHarga,
                    bold: true),
              ],
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),

      /// BOTTOM BAR
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10),
          ],
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text('Total Pembayaran',
                    style: TextStyle(color: Colors.grey)),
                Text(
                  formatRupiah(totalHarga),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: lanjutBayar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding:
                    const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              child: const Text('Buat Pesanan'),
            ),
          ],
        ),
      ),
    );
  }

  /// ===============================
  /// HELPER
  /// ===============================
  BoxDecoration box() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      );

  Widget rowTitle(IconData icon, String title) => Row(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      );

  InputDecoration input(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );

  Widget rowHarga(String label, int harga,
          {bool bold = false}) =>
      Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight:
                      bold ? FontWeight.bold : null)),
          Text(
            formatRupiah(harga),
            style: TextStyle(
                fontWeight:
                    bold ? FontWeight.bold : null),
          ),
        ],
      );
}
