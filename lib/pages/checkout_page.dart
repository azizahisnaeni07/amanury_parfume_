import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../utils/format_rupiah.dart';
import 'invoice_page.dart';
import '../data/cart_notifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> items;

  const CheckoutPage({super.key, required this.items});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final supabase = Supabase.instance.client;
  final namaC = TextEditingController();
  final alamatC = TextEditingController();

  int get totalHarga =>
      widget.items.fold(0, (sum, item) => sum + item.totalHarga);

  String tanggalHariIni() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  Future<void> lanjutBayar() async {
    if (namaC.text.isEmpty || alamatC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama & alamat wajib diisi'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final orderResponse = await supabase
          .from('orders')
          .insert({
            'user_id': user.id,
            'total_price': totalHarga,
            'customer_name': namaC.text,
            'address': alamatC.text,
            'status': 'pending',
          })
          .select()
          .single();

      final String orderId = orderResponse['id'];

      final List<Map<String, dynamic>> orderItems = widget.items.map((item) {
        return {
          'order_id': orderId,
          'product_id': item.produk.id,
          'quantity': item.qty,
          'price_at_purchase': item.itemPrice,
          'variant_name': item.variantName,
        };
      }).toList();

      await supabase.from('order_items').insert(orderItems);

      for (var item in widget.items) {
        if (item.id != null) {
          await supabase.from('cart').delete().eq('id', item.id!);
        }
      }

      cartCount.value = 0;

      if (!mounted) return;

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

      if (result == true) {
        if (!mounted) return;
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Error checkout: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Checkout'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionTitle('Detail Pengiriman'),
          const SizedBox(height: 16),
          TextField(
            controller: namaC,
            decoration: const InputDecoration(
              hintText: 'Nama Lengkap Penerima',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: alamatC,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Alamat Lengkap Pengiriman',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionTitle('Ringkasan Pesanan'),
          const SizedBox(height: 16),
          ...widget.items.map((item) => _buildItemRow(item)),
          const Divider(height: 32),
          _buildPriceRow('Subtotal', totalHarga),
          _buildPriceRow('Biaya Pengiriman', 0),
          const SizedBox(height: 12),
          _buildPriceRow('Total Pembayaran', totalHarga, isTotal: true),
          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: Container(
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
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  formatRupiah(totalHarga),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF6ADAFF),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: ElevatedButton(
                onPressed: lanjutBayar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFE500),
                  foregroundColor: Colors.black,
                ),
                child: const Text('Buat Pesanan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildItemRow(CartItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.produk.nama,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${item.qty}x ${item.variantName}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            formatRupiah(item.totalHarga),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, int price, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.black : Colors.grey[600],
            ),
          ),
          Text(
            formatRupiah(price),
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold,
              fontSize: isTotal ? 20 : 14,
              color: isTotal ? const Color(0xFF6ADAFF) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
