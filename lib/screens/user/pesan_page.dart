import 'package:flutter/material.dart';
//import 'package:utama/screens/user/pesan_page.dart';
//import 'riwayat_page.dart' as riwayat;
//import 'profil_page.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _imageList = [
    'assets/museum1.jpg',
    'assets/museum2.jpg',
    'assets/museum3.jpg',
  ];

  void _onNavTapped(int index) {
    if (index == 0) {
      // Beranda: tidak melakukan apa-apa, tetap di halaman ini
      setState(() {
        _selectedIndex = 0;
      });
    } else if (index == 1) {
      //Navigator.push(
       // context,
       // MaterialPageRoute(builder: (context) => riwayat.RiwayatPage()),
      //);
    } else if (index == 2) {
     // Navigator.push(
       // context,
       // MaterialPageRoute(builder: (context) => ProfilPage()),
      //);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Nama Museum',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 12),

              // PageView Gambar
              SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _imageList.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: AssetImage(_imageList[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 8),

              // Indikator halaman
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _imageList.length,
                  (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 12 : 8,
                    height: _currentPage == index ? 12 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _currentPage == index
                              ? Colors.black
                              : Colors.grey[400],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Deskripsi Museum
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blueAccent),
                          SizedBox(width: 8),
                          Text(
                            "Tentang Museum",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Museum Nasional (Museum Gajah) adalah museum tertua di Indonesia yang menyimpan lebih dari 140.000 koleksi bersejarah, termasuk arca Hindu-Buddha, keramik kuno, dan benda budaya nusantara.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '📍 Lokasi: Jakarta Pusat\n🕒 Jam Buka: 08.00 - 16.00 WIB\n🎟️ Harga Tiket: Rp25.000\n🛎️ Fasilitas: Parkir, Panduan Wisata, Toilet, Mushola, Akses Disabilitas',
                        style: TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                   // Navigator.push(
                     // context,
                     // MaterialPageRoute(builder: (context) => PesanPage()),
                    //);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 3,
                    side: BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text("Pesan Tiket"),
                ),
              ),
            ],
          ),
        ),
      ),
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

