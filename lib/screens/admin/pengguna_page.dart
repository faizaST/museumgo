import 'package:flutter/material.dart';
//import 'pemesanan_page.dart';
//import 'package:utama/screens/user/profil_page.dart';
import 'admin_home_page.dart';

class PenggunaPage extends StatefulWidget {
  const PenggunaPage({super.key});

  @override
  State<PenggunaPage> createState() => _PenggunaPageState();
}

class _PenggunaPageState extends State<PenggunaPage> {
  int _selectedIndex = 0;

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigasi berdasarkan index menggunakan push
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminHomePage()),
        );
        break;
      case 1:
        //Navigator.push(
        //context,
        //MaterialPageRoute(builder: (context) => const PemesananPage()),
        //);
        break;
      case 2:
        //Navigator.push(
        //context,
        //MaterialPageRoute(builder: (context) => const ProfilPage()),
        //);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> penggunaList = [
      {"nama": "Ayu Setiawan", "email": "ayu@gmail.com", "jumlahTiket": 3},
      {"nama": "Budi Hartono", "email": "budi@gmail.com", "jumlahTiket": 5},
      {"nama": "Citra Larasati", "email": "citra@gmail.com", "jumlahTiket": 2},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Data Pengguna',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: penggunaList.length,
        itemBuilder: (context, index) {
          final user = penggunaList[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: Text(user['nama']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['email']),
                  const SizedBox(height: 4),
                  Text(
                    'Tiket dibeli: ${user['jumlahTiket']}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Konfirmasi'),
                          content: Text('Blokir pengguna ${user['nama']}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Pengguna ${user['nama']} diblokir.',
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'Blokir',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Blokir'),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.grey[300],
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Data Pemesanan',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
