import 'package:flutter/material.dart';
import '../models/produk.dart';
import '../utils/format_rupiah.dart';
import '../data/cart_notifier.dart';
import 'cart_page.dart';
import '../utils/supabase_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailProdukPage extends StatefulWidget {
  final Produk produk;

  const DetailProdukPage({super.key, required this.produk});

  @override
  State<DetailProdukPage> createState() => _DetailProdukPageState();
}

class _DetailProdukPageState extends State<DetailProdukPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> updateCartBadge() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('cart')
          .select('quantity')
          .eq('user_id', user.id);

      final List data = response as List;
      int total = 0;
      for (var item in data) {
        total += (item['quantity'] as int);
      }
      cartCount.value = total;
    } catch (e) {
      debugPrint("Error update badge: $e");
    }
  }

  void showPilihUkuran(BuildContext context, {required bool beliLangsung}) {
    String selectedUkuran = widget.produk.varianHarga.keys.first;
    final supabase = Supabase.instance.client;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            int hargaFinal =
                widget.produk.varianHarga[selectedUkuran] ??
                widget.produk.harga;

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
                  Text(
                    widget.produk.nama,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatRupiah(hargaFinal),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF6ADAFF),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Pilih Ukuran',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: widget.produk.varianHarga.keys.map((ukuran) {
                      final aktif = selectedUkuran == ukuran;
                      return ChoiceChip(
                        label: Text(ukuran),
                        selected: aktif,
                        showCheckmark: false,
                        selectedColor: const Color(0xFF6ADAFF),
                        onSelected: (_) =>
                            setModalState(() => selectedUkuran = ukuran),
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: aktif
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final user = supabase.auth.currentUser;
                        if (user == null) return;
                        try {
                          final existing = await supabase
                              .from('cart')
                              .select()
                              .eq('user_id', user.id)
                              .eq('product_id', widget.produk.id)
                              .eq('variant_name', selectedUkuran)
                              .maybeSingle();

                          if (existing != null) {
                            await supabase
                                .from('cart')
                                .update({'quantity': existing['quantity'] + 1})
                                .eq('id', existing['id']);
                          } else {
                            await supabase.from('cart').insert({
                              'user_id': user.id,
                              'product_id': widget.produk.id,
                              'quantity': 1,
                              'variant_name': selectedUkuran,
                            });
                          }

                          await updateCartBadge();
                          if (!context.mounted) return;
                          Navigator.pop(context);

                          if (beliLangsung) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CartPage(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ditambahkan ke keranjang'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } catch (e) {
                          debugPrint("Error: $e");
                        }
                      },
                      child: Text(
                        beliLangsung ? 'Beli Sekarang' : 'Masukkan Keranjang',
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
    final displayImages = widget.produk.images.isEmpty
        ? [widget.produk.image]
        : widget.produk.images;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.produk.nama, style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 400,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: displayImages.length,
                    itemBuilder: (context, index) {
                      final imgPath = displayImages[index];
                      return Container(
                        color: Colors.grey[50],
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: imgPath.startsWith('assets/')
                              ? Image.asset(
                                  imgPath,
                                  fit: BoxFit.contain,
                                  height: 320,
                                )
                              : (SupabaseHelper.getImageUrl(imgPath).isEmpty
                                    ? const Icon(
                                        Icons.image,
                                        size: 80,
                                        color: Colors.grey,
                                      )
                                    : Image.network(
                                        SupabaseHelper.getImageUrl(imgPath),
                                        fit: BoxFit.contain,
                                        height: 320,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                              Icons.broken_image,
                                              size: 80,
                                              color: Colors.grey,
                                            ),
                                      )),
                        ),
                      );
                    },
                  ),
                ),
                if (displayImages.length > 1)
                  Positioned(
                    bottom: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        displayImages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _currentPage == index
                                ? const Color(0xFF6ADAFF)
                                : Colors.grey[300],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.produk.nama,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        formatRupiah(widget.produk.harga),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF6ADAFF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6ADAFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.produk.kategori,
                      style: const TextStyle(
                        color: Color(0xFF6ADAFF),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Tentang Aroma Ini',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.produk.deskripsiLengkap,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(
                    height: 100,
                  ), // Beri padding bawah lebih banyak agar tidak tertutup bottom bar
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 100, // Beri tinggi eksplisit
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
            Expanded(
              child: OutlinedButton(
                onPressed: () => showPilihUkuran(context, beliLangsung: false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF6ADAFF), width: 2),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Keranjang',
                  style: TextStyle(
                    color: Color(0xFF6ADAFF),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => showPilihUkuran(context, beliLangsung: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6ADAFF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Beli Sekarang',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
