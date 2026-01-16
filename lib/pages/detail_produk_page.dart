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
  /// BOTTOM SHEET PILIH UKURAN
  /// ===============================
  void showPilihUkuran(
    BuildContext context, {
    required bool beliLangsung,
  }) {
    String selectedUkuran = produk.varianHarga.keys.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            int hargaFinal =
                produk.harga + produk.varianHarga[selectedUkuran]!;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// NAMA PRODUK
                  Text(
                    produk.nama,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// HARGA
                  Text(
                    formatRupiah(hargaFinal),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// PILIH UKURAN
                  const Text(
                    'Pilih Ukuran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 10,
                    children:
                        produk.varianHarga.keys.map((ukuran) {
                      final aktif = selectedUkuran == ukuran;
                      return ChoiceChip(
                        label: Text(ukuran),
                        selected: aktif,
                        selectedColor:
                            const Color(0xFF2563EB),
                        labelStyle: TextStyle(
                          color:
                              aktif ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (_) {
                          setState(() {
                            selectedUkuran = ukuran;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  /// BUTTON KONFIRMASI
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final produkFix = Produk(
                          nama:
                              '${produk.nama} ($selectedUkuran)',
                          deskripsi: produk.deskripsi,
                          deskripsiLengkap:
                              produk.deskripsiLengkap,
                          harga: hargaFinal,
                          image: produk.image,
                          kategori: produk.kategori,
                          varianHarga: produk.varianHarga,
                        );

                        final index = keranjang.indexWhere(
                          (item) =>
                              item.produk.nama ==
                              produkFix.nama,
                        );

                        if (index >= 0) {
                          keranjang[index].qty++;
                        } else {
                          keranjang
                              .add(CartItem(produk: produkFix));
                        }

                        cartCount.value = keranjang.fold(
                          0,
                          (sum, item) => sum + item.qty,
                        );

                        Navigator.pop(context);

                        if (beliLangsung) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CartPage(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                'Ditambahkan ($selectedUkuran)',
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF2563EB),
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        beliLangsung
                            ? 'Beli Sekarang'
                            : 'Masukkan Keranjang',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text(produk.nama),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 340,
              color: const Color(0xFFF3F4F6),
              child: Center(
                child: Image.asset(
                  produk.image,
                  fit: BoxFit.contain,
                  height: 280,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produk.nama,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    produk.deskripsiLengkap,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.8,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => showPilihUkuran(
                            context,
                            beliLangsung: false,
                          ),
                          child:
                              const Text('Tambah ke Keranjang'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => showPilihUkuran(
                            context,
                            beliLangsung: true,
                          ),
                          child: const Text('Beli Sekarang'),
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
