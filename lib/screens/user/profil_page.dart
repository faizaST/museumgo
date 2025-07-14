import 'dart:io';
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
  UserModel? _user;
  bool _isLoading = true;

  File? _selectedImage;

  int _selectedIndex = 2; // index ke-2 untuk Profil

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
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_user == null) return;

    try {
      await Supabase.instance.client
          .from('users')
          .update({'name': _nameController.text})
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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
                        backgroundImage:
                            _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : const AssetImage('assets/avatar.png')
                                    as ImageProvider,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 14,
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: _user?.email ?? '',
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Simpan Perubahan'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _logout,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Log Out',
                            style: TextStyle(fontWeight: FontWeight.bold),
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}