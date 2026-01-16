class Produk {
  final String nama;
  final String deskripsi;
  final String deskripsiLengkap;
  final int harga;
  final String image;
  final String kategori;

  /// VARIAN UKURAN + TAMBAHAN HARGA
  final Map<String, int> varianHarga;

  Produk({
    required this.nama,
    required this.deskripsi,
    required this.deskripsiLengkap,
    required this.harga,
    required this.image,
    required this.kategori,
    required this.varianHarga,
  });
}
