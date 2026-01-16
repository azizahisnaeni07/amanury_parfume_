import '../models/produk.dart';
import '../models/cart_item.dart';

final List<CartItem> keranjang = [];

final List<Produk> produkList = [
  Produk(
    nama: 'Tavisha',
    deskripsi:
        'Aroma Tavisha aroma yang tidak terlalu kuat, tetapi tetap meninggalkan kesan.',
    deskripsiLengkap: '''
- Karakter Aroma Tavisha
• Tenang & bijak  
• Lembut tapi punya prinsip  
• Suka aroma yang tidak terlalu kuat, tapi tetap meninggalkan kesan  
• Tampil segar dan bersih tanpa harus berlebihan
• Elegan  secara natural  

- Ketahanan Wangi Tavisha
• Bertahan 8-10 jam di kulit  
• Bisa bertahan lebih dari 12+jam di pakaian
• Cocok untuk aktivitas siang hari, ngantor, hangout, atau me time

''',
    harga: 25000,
    image: 'assets/images/tavisha.png',
    kategori: 'Women',
    varianHarga: {
      '10 ml': 10000,
      '30 ml': 25000,
      '50 ml': 35000,
      '100 ml': 50000,
    },
  ),

  Produk(
    nama: 'Lakshya',
    deskripsi:
        'Cocok untuk pria yang ingin tampil berkelas,modern,dan berkarakter,tanpa aroma yang terlalu berat atau tua',
    deskripsiLengkap: '''
- Karakter Aroma Lakshya
• Layered fresh fruity di awal, Floral Elegant di tengah, dan Warm Woody di akhir  
• Cocok untuk cuaca tropis dan bisa dipaaki siang atau malam  

- Ketahanan Wangi Lakshya
• Di kulit: 8-12 jam  
• Di pakaian: Hingga 18 jam
• Sillage: Medium to strong wangi terasa cukup luas namun tetap elegan, tidak menyengat

''',
    harga: 25000,
    image: 'assets/images/lakshya.png',
    kategori: 'Mans',
    varianHarga: {
      '10 ml': 10000,
      '30 ml': 25000,
      '50 ml': 35000,
      '100 ml': 50000,
    },
  ),

  Produk(
    nama: 'Annisha',
    deskripsi:
        'Parfum ini memiliki karakteristik manis, floral, dan hangat, yang memancarkan sisi feminin, romantis, dan elegan',
    deskripsiLengkap: '''
- Karakter Aroma Annisha
• Cocok untuk wanita yang ingin meninggalkan kesan mendalam tanpa perlu banyak bicara   
• Aromanya mampu menemani dari siang hingga malam, dari suasana kasual hingga formal   

- Ketahanan Wangi Annisha
• Kulit: 8-12 jam (bahkan bisa lebih)  
• Pakaian: Bisa bertahan 12 jam+ 
• Sillage: Medium ke strong wangi terasa mewah dan tahan lama tanpa menyengat 
''',
    harga: 25000,
    image: 'assets/images/annisha.png',
    kategori: 'Women',
    varianHarga: {
      '10 ml': 10000,
      '30 ml': 25000,
      '50 ml': 35000,
      '100 ml': 50000,
    },
  ),

  Produk(
    nama: 'Kavisha',
    deskripsi:
        'Parfume yang cocok untuk pribadi tenang, elegan, cerdas, dan intuitif',
    deskripsiLengkap: '''
- Karakter Aroma Kavisha
• Aromanya tidak mencolok tapi memikat seperti kepribadian yang lembut namun dalam 
• Pas untuk kamu yang menyukai kesederhanaan, keanggunan, dan ketenangan dalam satu sentuhan  

- Ketahanan Wangi Kavisha
• Kulit: 6-10 jam  
• Wangi terasa lembut dan menyati dengan kulit, terutama bagian creamy floral dan woody-nya yang muncul setelah beberapa jam
• Di pakaian: Hingga 16 jam  
• Aroma lebih bertahan lama, terutama nuansa orris butter dan white amber yang melekat lembut di serat kain.  
• Sillage (jangkauan aroma): Soft to Medium  
• Wanginya tidak menyengat, tapi tetap bisa dirasakan oleh orang di dekatmu  
• Cocok untuk yang ingin tampil wangi tanpa berlebihan  
''',
    harga: 25000,
    image: 'assets/images/kavisha.png',
    kategori: 'Women', 
    varianHarga: {
      '10 ml': 10000,
      '30 ml': 25000,
      '50 ml': 35000,
      '100 ml': 50000,
    },
  ),

  Produk(
    nama: 'Lively Embrace',
    deskripsi: 'Unisex dengan nuansa feminin yang dewasa.',
    deskripsiLengkap: '''
- Karakter Aroma Lively Embrace
• Manis & segar di awal kesan youthful & ceria 
• Floral lembut dengan sentuhan leather elegan, sensual, dan tegas  
• Hangat & creamy di akhir memberikan kesan mendalam dan memikat
• Cocok untuk momen spesial, acara formal, atau suasana romantis  
• Memberikan kesan romantis, percaya diri, dan berkelas 

- Ketahanan Wangi Lively Embrace
• Tahan 10-12jam di kulit  
• Bisa bertahan lebih dari 12 jam di pakaian
• Wangi tetap terasa meski setelah beraktivitas 
• Cocok untuk penggunaan harian maupun acara spesial dan outdoor 
• Semakin lama, aroma berubah menjadi lebih hangat dan lembut 
''',
    harga: 25000,
    image: 'assets/images/lively embrace.png',
    kategori: 'Unisex',
    varianHarga: {
      '10 ml': 10000,
      '30 ml': 25000,
      '50 ml': 35000,
      '100 ml': 50000,
    },
  ),
];
