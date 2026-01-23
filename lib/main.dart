import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import ini
import 'pages/login_page.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  // 1. Pastikan widget binding sudah terinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://uekmtnsmbhpnnpivgqgi.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVla210bnNtYmhwbm5waXZncWdpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg4MTc4MjksImV4cCI6MjA4NDM5MzgyOX0.Z36F4vFoLxnhF9oUePhXRpVxYCUL_vBi80PBRc2mLa4',
  );

  runApp(const MyApp());
}

// Shortcut untuk mengakses client supabase di mana saja
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Amanury Parfume',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF6ADAFF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6ADAFF),
          primary: const Color(0xFF6ADAFF),
          secondary: const Color(0xFFFFE500),
          surface: Colors.white,
          onPrimary: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6ADAFF),
            foregroundColor: Colors.black,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6ADAFF), width: 2),
          ),
        ),
      ),
      // Cek apakah user sudah login atau belum secara otomatis
      home: supabase.auth.currentSession == null
          ? const LoginPage()
          : const HomePage(), // Gantilah ke HomePage Anda nanti
    );
  }
}
