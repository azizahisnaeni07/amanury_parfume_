import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/produk.dart';
import '../data/cart_notifier.dart';
import '../utils/format_rupiah.dart';
import 'detail_produk_page.dart';
import 'cart_page.dart';
import 'order_history_page.dart';
import 'profile_page.dart';
import 'login_page.dart';
import '../utils/supabase_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;

  List<Produk> allProduk = [];
  bool isLoading = true;
  String selectedKategori = 'Semua';
  String searchQuery = '';
  String? avatarUrl;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchProfile();
    updateCartBadge();
  }

  Future<void> fetchProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await supabase
          .from('profiles')
          .select('avatar_url')
          .eq('id', user.id)
          .maybeSingle();

      if (data != null && data['avatar_url'] != null) {
        setState(() {
          avatarUrl = data['avatar_url'];
        });
      }
    } catch (e) {
      debugPrint("Error fetch profile: $e");
    }
  }

  Future<void> updateCartBadge() async {
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

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase
          .from('products')
          .select('*, categories(name), product_variants(*)')
          .order('created_at', ascending: false);

      final List data = response as List;

      setState(() {
        final List<dynamic> rawData = data;
        allProduk = rawData.map<Produk>((item) {
          String kategoriNama = 'Unisex';
          final categoriesData = item['categories'];
          if (categoriesData != null) {
            if (categoriesData is Map) {
              kategoriNama = categoriesData['name']?.toString() ?? 'Unisex';
            } else if (categoriesData is List && categoriesData.isNotEmpty) {
              kategoriNama = categoriesData[0]['name']?.toString() ?? 'Unisex';
            }
          }
          return Produk.fromMap(item, kategoriNama);
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error Supabase: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal mengambil data: $e")));
      }
      setState(() => isLoading = false);
    }
  }

  List<Produk> get filteredProduk {
    return allProduk.where((produk) {
      final cocokKategori =
          selectedKategori == 'Semua' || produk.kategori == selectedKategori;
      final cocokSearch = produk.nama.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      return cocokKategori && cocokSearch;
    }).toList();
  }

  void logout(BuildContext context) async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void showQuickPilihUkuran(
    BuildContext context,
    Produk produk, {
    required bool beliLangsung,
  }) {
    String selectedUkuran = produk.varianHarga.keys.first;

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
            int hargaFinal = produk.varianHarga[selectedUkuran] ?? produk.harga;

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
                    produk.nama,
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
                    children: produk.varianHarga.keys.map((ukuran) {
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
                              .eq('product_id', produk.id)
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
                              'product_id': produk.id,
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
                              SnackBar(
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('AMANURY'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
            ),
          ),
          ValueListenableBuilder<int>(
            valueListenable: cartCount,
            builder: (context, value, _) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartPage()),
                  ),
                ),
                if (value > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFE500),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        value.toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          _buildSearchField(),
          _buildCategoryFilter(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredProduk.isEmpty
                ? const Center(child: Text("Produk tidak ditemukan"))
                : _buildProductGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: searchController,
        onChanged: (value) => setState(() => searchQuery = value),
        decoration: const InputDecoration(
          hintText: 'Cari koleksi kami...',
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: ['Semua', 'Mans', 'Women', 'Unisex'].map((kategori) {
          final aktif = selectedKategori == kategori;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(kategori),
              selected: aktif,
              showCheckmark: false,
              selectedColor: const Color(0xFF6ADAFF),
              onSelected: (_) => setState(() => selectedKategori = kategori),
              labelStyle: TextStyle(
                color: Colors.black,
                fontWeight: aktif ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredProduk.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.65, // Sedikit lebih tinggi untuk menampung tombol
      ),
      itemBuilder: (context, index) {
        final produk = filteredProduk[index];
        final imageUrl = SupabaseHelper.getImageUrl(produk.image);

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailProdukPage(produk: produk)),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: produk.image.startsWith('assets/')
                        ? Image.asset(produk.image, fit: BoxFit.cover)
                        : (imageUrl.isEmpty
                              ? const Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                )
                              : Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                                  ),
                                )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produk.nama,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatRupiah(produk.harga),
                        style: const TextStyle(
                          color: Color(0xFF6ADAFF),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Tooltip(
                            message: 'Tambah ke Keranjang',
                            child: SizedBox(
                              width: 36,
                              height: 32,
                              child: ElevatedButton(
                                onPressed: () => showQuickPilihUkuran(
                                  context,
                                  produk,
                                  beliLangsung: false,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6ADAFF),
                                  foregroundColor: Colors.black,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Icon(
                                  Icons.add_shopping_cart_outlined,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: SizedBox(
                              height: 32,
                              child: ElevatedButton(
                                onPressed: () => showQuickPilihUkuran(
                                  context,
                                  produk,
                                  beliLangsung: true,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFE500),
                                  foregroundColor: Colors.black,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Beli',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
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
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final user = supabase.auth.currentUser;
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF6ADAFF)),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl!)
                        : null,
                    child: avatarUrl == null
                        ? const Icon(
                            Icons.person,
                            color: Color(0xFF6ADAFF),
                            size: 30,
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.email ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profil'),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
              fetchProfile(); // Refresh foto profil saat kembali
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Keluar', style: TextStyle(color: Colors.red)),
            onTap: () => logout(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
