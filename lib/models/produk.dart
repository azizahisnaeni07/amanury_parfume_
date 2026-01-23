import 'package:flutter/material.dart';

class Produk {
  final String id;
  final String nama;
  final String deskripsi;
  final String deskripsiLengkap;
  final int harga;
  final String image;
  final List<String> images;
  final String kategori;

  /// VARIAN UKURAN + TAMBAHAN HARGA
  final Map<String, int> varianHarga;

  Produk({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.deskripsiLengkap,
    required this.harga,
    required this.image,
    required this.images,
    required this.kategori,
    required this.varianHarga,
  });

  factory Produk.fromMap(Map<String, dynamic> map, String kategoriNama) {
    Map<String, int> variants = {};
    final int basePrice =
        (double.tryParse(map['price']?.toString() ?? '0') ?? 0).toInt();

    // 1. Ambil varian dari Joined Table 'product_variants'
    if (map['product_variants'] != null && map['product_variants'] is List) {
      final List<dynamic> variantsList = map['product_variants'];
      for (var v in variantsList) {
        final name = v['name']?.toString() ?? 'Unknown';
        final vPrice = (double.tryParse(v['price']?.toString() ?? '0') ?? 0)
            .toInt();
        variants[name] = vPrice;
      }
    }

    // 2. Fallback untuk format JSONB legacy jika variants masih kosong
    if (variants.isEmpty && map['variants'] != null) {
      try {
        final List<dynamic> variantsList = map['variants'] is List
            ? map['variants']
            : [];
        for (var v in variantsList) {
          final name = v['name']?.toString() ?? 'Unknown';
          final price = (double.tryParse(v['price']?.toString() ?? '0') ?? 0)
              .toInt();
          variants[name] = price;
        }
      } catch (e) {
        debugPrint("Error parsing legacy variants: $e");
      }
    }

    // 3. Fallback jika map['varian_harga'] ada (legacy data format)
    if (variants.isEmpty &&
        map['varian_harga'] != null &&
        map['varian_harga'] is Map) {
      variants = Map<String, int>.from(map['varian_harga']);
    }

    // 4. Jika TETAP kosong, beri default 'All Size' dengan harga dasar
    if (variants.isEmpty) {
      variants['All Size'] = basePrice;
    }

    // AMBIL GAMBAR
    List<String> allImages = [];
    String primaryImage = map['image_url']?.toString() ?? '';

    if (primaryImage.isNotEmpty) {
      allImages.add(primaryImage);
    }

    final List? multiImages = map['image_urls'] as List?;
    if (multiImages != null && multiImages.isNotEmpty) {
      for (var img in multiImages) {
        final imgStr = img.toString();
        if (imgStr.isNotEmpty && !allImages.contains(imgStr)) {
          allImages.add(imgStr);
        }
      }
    }

    // Fallback jika tidak ada gambar sama sekali
    if (allImages.isEmpty) {
      primaryImage = '';
    } else if (primaryImage.isEmpty) {
      primaryImage = allImages.first;
    }

    return Produk(
      id: map['id']?.toString() ?? '',
      nama: map['name']?.toString() ?? '',
      harga: basePrice,
      deskripsi: map['description']?.toString() ?? '',
      deskripsiLengkap: map['description']?.toString() ?? '',
      image: primaryImage,
      images: allImages,
      kategori: kategoriNama,
      varianHarga: variants,
    );
  }
}
