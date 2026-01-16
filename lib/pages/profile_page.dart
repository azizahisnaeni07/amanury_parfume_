import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/user_data.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController namaC;
  late TextEditingController emailC;
  late TextEditingController alamatC;
  late TextEditingController passwordC;
  late TextEditingController phoneC;

  bool showPassword = false;
  File? profileImage;

  @override
  void initState() {
    super.initState();

    namaC = TextEditingController(text: UserData.nama ?? '');
    emailC = TextEditingController(text: UserData.email ?? '');
    alamatC = TextEditingController(text: UserData.alamat ?? '');
    passwordC = TextEditingController(text: UserData.password ?? '');
    phoneC = TextEditingController(text: UserData.phone ?? '');

    /// LOAD FOTO JIKA ADA
    if (UserData.profileImagePath != null &&
        UserData.profileImagePath!.isNotEmpty) {
      profileImage = File(UserData.profileImagePath!);
    }
  }

  /// ===============================
  /// PILIH FOTO
  /// ===============================
  Future<void> pilihFoto(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() {
        profileImage = File(picked.path);
        UserData.profileImagePath = picked.path;
      });
    }
  }

  /// ===============================
  /// SIMPAN PROFILE
  /// ===============================
  void simpanProfile() {
    if (namaC.text.isEmpty ||
        emailC.text.isEmpty ||
        alamatC.text.isEmpty ||
        passwordC.text.isEmpty ||
        phoneC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi')),
      );
      return;
    }

    UserData.nama = namaC.text;
    UserData.email = emailC.text;
    UserData.alamat = alamatC.text;
    UserData.password = passwordC.text;
    UserData.phone = phoneC.text;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile berhasil disimpan'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// ===============================
  /// LUPA PASSWORD
  /// ===============================
  void lupaPassword() {
    final newPassC = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ganti Password'),
        content: TextField(
          controller: newPassC,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password Baru'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPassC.text.isEmpty) return;

              setState(() {
                UserData.password = newPassC.text;
                passwordC.text = newPassC.text;
              });

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password berhasil diganti'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile User'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// FOTO PROFILE
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.deepPurple.shade100,
                  backgroundImage:
                      profileImage != null ? FileImage(profileImage!) : null,
                  child: profileImage == null
                      ? const Icon(Icons.person,
                          size: 55, color: Colors.white)
                      : null,
                ),
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (_) => Wrap(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text('Kamera'),
                            onTap: () {
                              Navigator.pop(context);
                              pilihFoto(ImageSource.camera);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo),
                            title: const Text('Galeri'),
                            onTap: () {
                              Navigator.pop(context);
                              pilihFoto(ImageSource.gallery);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit,
                        size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            TextField(
              controller: namaC,
              decoration: const InputDecoration(
                labelText: 'Nama',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: emailC,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: phoneC,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'No. Handphone',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: alamatC,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Alamat',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: passwordC,
              obscureText: !showPassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    showPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                ),
                border: const OutlineInputBorder(),
              ),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: lupaPassword,
                child: const Text('Lupa / Ganti Password?'),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: simpanProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                child: const Text(
                  'Simpan Profile',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
