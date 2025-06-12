import 'package:flutter/material.dart';
//import 'package:utama/screens/admin/admin_home_page.dart';
//import 'package:utama/screens/admin/pemesanan_page.dart';
import 'admin_profil_body_page.dart';

class AdminProfilFullPage extends StatefulWidget {
  const AdminProfilFullPage({super.key});

  @override
  State<AdminProfilFullPage> createState() => _AdminProfilFullPageState();
}

class _AdminProfilFullPageState extends State<AdminProfilFullPage> {
  int _selectedIndex = 2;

  final TextEditingController _namaController = TextEditingController(
    text: 'Admin Utama',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'admin@utama.com',
  );

  void _onNavTapped(int index) {
    if (index == _selectedIndex) return;

    Widget destination;
    switch (index) {
      case 0:
        //destination = const AdminHomePage();
        break;
      case 1:
        //destination = const PemesananPage();
        break;
      case 2:
        return;
      default:
        return;
    }

    //Navigator.pushReplacement(
      //context,
      //MaterialPageRoute(builder: (_) => destination),
    //);
  }

  void _logout() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Apakah kamu yakin ingin logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Berhasil logout')),
                  );
                },
                child: const Text('Ya'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profil Admin'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: AdminProfilBody(
        namaController: _namaController,
        emailController: _emailController,
        onLogout: _logout,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Pemesanan',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}