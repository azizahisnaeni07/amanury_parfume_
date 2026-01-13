import 'package:flutter/material.dart';
import '../data/data_produk.dart';
import '../models/produk.dart';
import '../data/cart_notifier.dart';
import '../utils/format_rupiah.dart';
import 'detail_produk_page.dart';
import 'cart_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedKategori = 'Semua';

  List<Produk> get filteredProduk {
    if (selectedKategori == 'Semua') return produkList;
    return produkList
        .where((p) => p.kategori == selectedKategori)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          'Amanury Parfume',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: cartCount,
            builder: (context, value, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CartPage(),
                        ),
                      );
                    },
                  ),
                  if (value > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: CircleAvatar(
                        radius: 9,
                        backgroundColor: Colors.red,
                        child: Text(
                          value.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          /// ===============================
          /// KATEGORI
          /// ===============================
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['Semua', 'Mans', 'Women', 'Unisex'].map((kategori) {
                final aktif = selectedKategori == kategori;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChoiceChip(
                    label: Text(kategori),
                    selected: aktif,
                    selectedColor: Colors.deepPurple,
                    labelStyle: TextStyle(
                      color: aktif ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) {
                      setState(() {
                        selectedKategori = kategori;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          /// ===============================
          /// GRID PRODUK
          /// ===============================
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredProduk.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,

                ///  CARD LEBIH PENDEK & SEIMBANG
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final Produk produk = filteredProduk[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DetailProdukPage(produk: produk),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 6,
                          color: Colors.black12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        /// ===============================
                        /// GAMBAR (BESAR & SEIMBANG)
                        /// ===============================
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Image.asset(
                              produk.image,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        /// ===============================
                        /// INFO
                        /// ===============================
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  produk.nama,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatRupiah(produk.harga),
                                  style: const TextStyle(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  produk.deskripsi,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
