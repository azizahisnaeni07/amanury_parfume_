import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;
  final namaC = TextEditingController();
  final alamatC = TextEditingController();
  final phoneC = TextEditingController();
  bool _isLoading = false;
  String? avatarUrl;
  Uint8List? profileImageBytes;

  @override
  void initState() {
    super.initState();
    _getInitialProfile();
  }

  Future<void> _getInitialProfile() async {
    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser!.id;
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (data != null) {
        setState(() {
          namaC.text = data['full_name'] ?? '';
          alamatC.text = data['address'] ?? '';
          phoneC.text = data['phone_number'] ?? '';
          avatarUrl = data['avatar_url'];
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> pilihFoto(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 50);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _isLoading = true);
      try {
        final userId = supabase.auth.currentUser!.id;
        final fileName = '$userId-avatar.${picked.name.split('.').last}';
        await supabase.storage
            .from('avatars')
            .uploadBinary(
              fileName,
              bytes,
              fileOptions: const FileOptions(upsert: true),
            );
        final publicUrl = supabase.storage
            .from('avatars')
            .getPublicUrl(fileName);

        // Tambahkan timestamp agar browser/flutter mengabaikan cache jika nama file sama
        final newAvatarUrl =
            "$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}";

        // AUTO-SAVE ke tabel profiles
        await supabase.from('profiles').upsert({
          'id': userId,
          'avatar_url': newAvatarUrl,
          'updated_at': DateTime.now().toIso8601String(),
        });

        setState(() {
          profileImageBytes = bytes;
          avatarUrl = newAvatarUrl;
        });
      } catch (e) {
        debugPrint("Error: $e");
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> simpanProfile() async {
    if (namaC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama wajib diisi'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('profiles').upsert({
        'id': userId,
        'full_name': namaC.text,
        'address': alamatC.text,
        'phone_number': phoneC.text,
        'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil diperbarui'),
          backgroundColor: Color(0xFF6ADAFF),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Profil Saya'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[50],
                        backgroundImage: profileImageBytes != null
                            ? MemoryImage(profileImageBytes!)
                            : (avatarUrl != null
                                      ? NetworkImage(avatarUrl!)
                                      : null)
                                  as ImageProvider?,
                        child: (profileImageBytes == null && avatarUrl == null)
                            ? const Icon(
                                Icons.person_outline,
                                size: 60,
                                color: Color(0xFF6ADAFF),
                              )
                            : null,
                      ),
                      GestureDetector(
                        onTap: () => _showPickerOptions(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF6ADAFF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  TextField(
                    controller: namaC,
                    decoration: const InputDecoration(
                      hintText: 'Nama Lengkap',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: supabase.auth.currentUser?.email,
                      prefixIcon: const Icon(Icons.email_outlined),
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneC,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Nomor Telepon',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: alamatC,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Alamat Lengkap',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : simpanProfile,
                      child: const Text('Simpan Perubahan'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Ambil Foto'),
              onTap: () {
                Navigator.pop(context);
                pilihFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_outlined),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                pilihFoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
