import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'laporan_page.dart';
import 'pemesanan_page.dart';
import 'pengguna_page.dart';
import 'admin_profil_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  int pengunjung = 0;
  int tiketTerjual = 0;
  int pendapatan = 0;
  int menungguKonfirmasi = 0;

  final primaryColor = const Color(0xFF2563EB);

  final List<String> _titles = const [
    'Dashboard Admin',
    'Data Pemesanan',
    'Profil Admin',
  ];

  @override
  void initState() {
    super.initState();
    final argIndex = Get.arguments as int?;
    _selectedIndex = argIndex ?? 0;
    _loadStatistik();
  }

  Future<void> _loadStatistik() async {
    final client = Supabase.instance.client;
    final now = DateTime.now();
    final awal = DateTime(now.year, now.month, 1);
    final akhir = DateTime(now.year, now.month + 1, 0);

    try {
      final konfirmasi = await client
          .from('pemesanan')
          .select()
          .eq('status', 'Dikonfirmasi')
          .gte('tanggal', awal)
          .lte('tanggal', akhir);

      final menunggu = await client
          .from('pemesanan')
          .select()
          .eq('status', 'Menunggu Konfirmasi') // ✅ diperbaiki dari 'Menunggu'
          .gte('tanggal', awal)
          .lte('tanggal', akhir);

      setState(() {
        pengunjung = konfirmasi.length;
        tiketTerjual = konfirmasi.fold(
          0,
          (sum, item) => sum + (item['jumlah'] as int? ?? 0),
        );
        pendapatan = konfirmasi.fold(
          0,
          (sum, item) => sum + (item['total'] as int? ?? 0),
        );
        menungguKonfirmasi = menunggu.length;
      });
    } catch (e) {
      print('❌ Gagal memuat statistik: $e');
    }
  }

  void _onNavTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) _loadStatistik();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _DashboardPage(
        pengunjung: pengunjung,
        tiket: tiketTerjual,
        pendapatan: pendapatan,
        menunggu: menungguKonfirmasi,
        primaryColor: primaryColor,
      ),
      const PemesananPage(),
      const AdminProfilPage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE4EBFC),
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        selectedItemColor: primaryColor,
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

class _DashboardPage extends StatelessWidget {
  final int pengunjung;
  final int tiket;
  final int pendapatan;
  final int menunggu;
  final Color primaryColor;

  const _DashboardPage({
    required this.pengunjung,
    required this.tiket,
    required this.pendapatan,
    required this.menunggu,
    required this.primaryColor,
  });

  String _getFormattedDate() {
    final now = DateTime.now();
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(now);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selamat Datang, Admin!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _getFormattedDate(),
            style: const TextStyle(fontSize: 13, color: Color(0xFF2563EB)),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatCard(
                title: 'Pengunjung',
                value: '$pengunjung',
                icon: Icons.people,
                color: primaryColor,
              ),
              _StatCard(
                title: 'Tiket Terjual',
                value: '$tiket',
                icon: Icons.confirmation_num,
                color: Colors.green,
              ),
              _StatCard(
                title: 'Pendapatan',
                value: 'Rp${NumberFormat('#,###', 'id_ID').format(pendapatan)}',
                icon: Icons.attach_money,
                color: Colors.orange,
              ),
              _StatCard(
                title: 'Menunggu Konfirmasi',
                value: '$menunggu',
                icon: Icons.schedule,
                color: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Kelola Data',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Center(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _MenuItem(
                  icon: Icons.people,
                  label: 'Pengguna',
                  color: primaryColor,
                  page: PenggunaPage(),
                ),
                _MenuItem(
                  icon: Icons.bar_chart,
                  label: 'Laporan',
                  color: Colors.deepPurple,
                  page: LaporanPage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Widget page;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120, // 📌 Ukuran card diperbesar dari 90 → 120
      child: GestureDetector(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => page),
            ),
        child: Card(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 18,
            ), // 📌 Tambah padding
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: color,
                ), // 📌 Ikon diperbesar dari 26 → 32
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                  ), // 📌 Font size sedikit dibesarkan
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 46) / 2,
      child: Card(
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.1),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
