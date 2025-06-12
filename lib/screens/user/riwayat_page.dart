import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  int _selectedIndex = 1;

  final List<Map<String, dynamic>> riwayat = [
    {
      'namaMuseum': 'Museum Nasional',
      'tanggal': '27/10/2024',
      'jumlahTiket': 2,
      'status': 'Selesai',
    },
    {
      'namaMuseum': 'Museum Batik',
      'tanggal': '27/10/2024',
      'jumlahTiket': 1,
      'status': 'Dibatalkan',
    },
    {
      'namaMuseum': 'Museum Keris',
      'tanggal': '27/10/2024',
      'jumlahTiket': 4,
      'status': 'Selesai',
    },
  ];

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        //Navigator.pushReplacement(
          //context,
          //MaterialPageRoute(builder: (_) => home.UserHomePage()),
        //);
        break;
      case 1:
        break;
      case 2:
        //Navigator.pushReplacement(
          //context,
          //MaterialPageRoute(builder: (_) => ProfilPage()),
        //);
        break;
    }
  }

  void _showDetailPopup(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text(
              'Detail Pemesanan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nama Museum: ${data['namaMuseum']}'),
                Text('Tanggal Kunjungan: ${data['tanggal']}'),
                Text('Jumlah Tiket: ${data['jumlahTiket']}'),
                Text(
                  'Status: ${data['status']}',
                  style: TextStyle(
                    color:
                        data['status'] == 'Selesai' ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 12),
                InkWell(
  onTap: () async {
    final url = data['buktiPembayaranUrl'] ?? '';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka file.')),
      );
    }
  },
  child: Text(
    'Lihat Bukti Pembayaran',
    style: TextStyle(color: Colors.blue),
  ),
)

              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Tutup'),
              ),
            ],
          ),
    );
  }

  Widget buildRiwayatCard(Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () => _showDetailPopup(data),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black87),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['namaMuseum'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text('Tanggal ${data['tanggal']}'),
                  Text('Jumlah Tiket: ${data['jumlahTiket']}'),
                ],
              ),
            ),
            Text(
              data['status'],
              style: TextStyle(
                color: data['status'] == 'Selesai' ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Pemesanan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(children: riwayat.map(buildRiwayatCard).toList()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}


