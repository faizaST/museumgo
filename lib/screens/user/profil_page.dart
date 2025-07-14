import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final _box = GetStorage();
  final AuthService _authService = AuthService();
  final _nameController = TextEditingController();
  final Color primaryColor = const Color(0xFF2563EB);

  UserModel? _user;
  bool _isLoading = true;

  Uint8List? _imageBytes;
  XFile? _pickedFile;

  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getCurrentUserProfile();
      setState(() {
        _user = userData;
        _nameController.text = userData?.name ?? '';
        _isLoading = false;
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat profil: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _pickedFile = picked;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_user == null) return;
    String? imageUrl;

    try {
      if (_imageBytes != null && _pickedFile != null) {
        final fileExt = _pickedFile!.path.split('.').last;
        final fileName = '${_user!.userId}.$fileExt';
        final filePath = 'user-avatars/$fileName';

        await Supabase.instance.client.storage
            .from('user-avatars')
            .uploadBinary(
              filePath,
              _imageBytes!,
              fileOptions: const FileOptions(upsert: true),
            );

        imageUrl = Supabase.instance.client.storage
            .from('user-avatars')
            .getPublicUrl(filePath);
      }

      await Supabase.instance.client
          .from('users')
          .update({
            'name': _nameController.text,
            if (imageUrl != null) 'foto_url': imageUrl,
          })
          .eq('user_id', _user!.userId);

      Get.snackbar(
        'Berhasil',
        'Profil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
      );

      _loadUserData();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _logout() {
    Get.defaultDialog(
      title: 'Konfirmasi',
      middleText: 'Apakah kamu yakin ingin logout?',
      textCancel: 'Batal',
      textConfirm: 'Ya',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await _authService.logout();
        _box.erase();
        Get.offAllNamed('/login');
        Get.snackbar(
          'Logout',
          'Berhasil logout',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  void _onNavTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) Get.offAllNamed('/user_home');
    if (index == 1) Get.offAllNamed('/riwayat');
    if (index == 2) Get.offAllNamed('/profil');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage:
                            _imageBytes != null
                                ? MemoryImage(_imageBytes!)
                                : (_user?.fotoUrl.isNotEmpty ?? false)
                                ? NetworkImage(_user!.fotoUrl)
                                : null,
                        child:
                            (_imageBytes == null &&
                                    (_user?.fotoUrl.isEmpty ?? true))
                                ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                )
                                : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama',
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: _user?.email ?? '',
                      ),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _saveChanges,
                        child: const Text(
                          'Simpan Perubahan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _logout,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Log Out',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        selectedItemColor: primaryColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}