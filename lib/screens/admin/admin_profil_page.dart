import 'package:flutter/material.dart';
import 'admin_profil_body_page.dart';

class AdminProfilPage extends StatefulWidget {
  const AdminProfilPage({super.key});

  @override
  State<AdminProfilPage> createState() => _AdminProfilPageState();
}

class _AdminProfilPageState extends State<AdminProfilPage> {
  final TextEditingController _namaController = TextEditingController(
    text: 'Admin Utama',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'admin@utama.com',
  );

  void _logout() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Berhasil logout')));
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Profil Admin'),
    ),
    body: AdminProfilBody(
      namaController: _namaController,
      emailController: _emailController,
      onLogout: _logout,
    ),
  );
}

}