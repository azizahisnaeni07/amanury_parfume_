import 'package:flutter/material.dart';
import '../data/order_data.dart';
import '../utils/format_rupiah.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
        centerTitle: true,
      ),
      body: orderHistory.isEmpty
          ? const Center(
              child: Text(
                'Belum ada pesanan',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orderHistory.length,
              itemBuilder: (context, index) {
                final order = orderHistory[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanggal: ${order.tanggal.toLocal()}'
                              .toString()
                              .split('.')[0],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 8),

                        ...order.items.map(
                          (item) => Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              '${item.produk.nama} x${item.qty}',
                              style: const TextStyle(
                                  color: Colors.black54),
                            ),
                          ),
                        ),

                        const Divider(height: 24),

                        Text(
                          'Total: ${formatRupiah(order.totalHarga)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          'Status: Berhasil',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
