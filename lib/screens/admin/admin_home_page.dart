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

  final List<String> _titles = const [
    'Dashboard Admin',
    'Data Pemesanan',
    'Profil Admin',
  ];

  @override
  void initState() {
    super.initState();

    // Jika ada arguments dari Get.toNamed('/admin-home', arguments: 1)
    final argIndex = Get.arguments as int?;
    _selectedIndex = argIndex ?? 0;

    _loadStatistik();
  }

  Future<void> _loadStatistik() async {
    final client = Supabase.instance.client;
    final now = DateTime.now();
    final awal = DateTime(now.year, now.month, 1);
    final akhir = DateTime(now.year, now.month + 1, 0);
    final formatter = DateFormat('yyyy-MM-dd');

    try {
      final konfirmasi = await client
          .from('pemesanan')
          .select()
          .eq('status', 'Dikonfirmasi')
          .gte('tanggal', formatter.format(awal))
          .lte('tanggal', formatter.format(akhir));

      final menunggu = await client
          .from('pemesanan')
          .select()
          .eq('status', 'Menunggu')
          .gte('tanggal', formatter.format(awal))
          .lte('tanggal', formatter.format(akhir));

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
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      _loadStatistik();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _DashboardPage(
        pengunjung: pengunjung,
        tiket: tiketTerjual,
        pendapatan: pendapatan,
        menunggu: menungguKonfirmasi,
      ),
      const PemesananPage(),
      const AdminProfilPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
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

class _DashboardPage extends StatelessWidget {
  final int pengunjung;
  final int tiket;
  final int pendapatan;
  final int menunggu;

  const _DashboardPage({
    required this.pengunjung,
    required this.tiket,
    required this.pendapatan,
    required this.menunggu,
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
            style: const TextStyle(fontSize: 13, color: Colors.grey),
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
                color: Colors.blue,
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
                  color: Colors.blue,
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
      width: 90,
      child: GestureDetector(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => page),
            ),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 26, color: color),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: const TextStyle(fontSize: 12),
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
      width: (MediaQuery.of(context).size.width - 48) / 2,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
