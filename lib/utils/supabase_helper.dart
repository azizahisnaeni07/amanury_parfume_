import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseHelper {
  static String getImageUrl(String path) {
    if (path.trim().isEmpty) {
      return '';
    }

    if (path.startsWith('http')) {
      return path;
    }

    if (path.startsWith('assets/')) {
      return path;
    }

    // Default ke bucket 'products' jika bukan aset lokal atau URL lengkap
    final url = Supabase.instance.client.storage
        .from('products')
        .getPublicUrl(path);

    debugPrint('DEBUG: Image Path: "$path" -> Generated URL: $url');
    return url;
  }
}
