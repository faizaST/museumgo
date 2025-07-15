import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/pesan_model.dart';
import '../../services/pesan_service.dart';
import 'user_home_page.dart' as home;
import 'profil_page.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  final _service = PemesananService();
  int _selectedIndex = 1;
  bool _isLoading = true;
  List<Tiket> _riwayat = [];

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      Get.snackbar(
        'Error',
        'User tidak ditemukan. Silakan login ulang.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final data = await _service.ambilPemesananUser(user.id);
      setState(() {
        _riwayat =
            data.map((e) {
              return Tiket(
                userId: e['user_id'],
                nama: e['nama'],
                tanggal: e['tanggal'],
                jumlah: e['jumlah'],
                total: e['total'],
                buktiUrl: e['bukti_url'],
                status: e['status'] ?? 'Menunggu Konfirmasi',
              );
            }).toList();
        _isLoading = false;
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Get.offAll(() => const home.UserHomePage());
        break;
      case 1:
        break;
      case 2:
        Get.offAll(() => const ProfilPage());
        break;
    }
  }

  void _showDetailPopup(Tiket tiket) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: const Text(
              'Detail Pemesanan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nama: ${tiket.nama}'),
                Text('Tanggal Kunjungan: ${tiket.tanggal}'),
                Text('Jumlah Tiket: ${tiket.jumlah}'),
                Text('Status: ${tiket.status}'),
                Text(
                  'Total: Rp ${tiket.total}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                if (tiket.buktiUrl.isNotEmpty)
                  InkWell(
                    onTap: () async {
                      final url = Uri.parse(tiket.buktiUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        Get.snackbar(
                          'Gagal',
                          'Tidak dapat membuka file.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    child: Row(
                      children: const [
                        Icon(
                          Icons.picture_as_pdf_outlined,
                          color: Color(0xFF2563EB),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Bukti Pembayaran',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Tutup'),
              ),
            ],
          ),
    );
  }

  Widget buildRiwayatCard(Tiket tiket) {
    Color statusColor;
    switch (tiket.status) {
      case 'Terverifikasi':
        statusColor = Colors.green;
        break;
      case 'Ditolak':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return GestureDetector(
      onTap: () => _showDetailPopup(tiket),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF2563EB)),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tiket.nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Tanggal: ${tiket.tanggal}'),
                    Text('Jumlah Tiket: ${tiket.jumlah}'),
                    Text(
                      'Status: ${tiket.status}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Riwayat Pemesanan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: primaryColor),
              )
              : RefreshIndicator(
                onRefresh: _loadRiwayat,
                child:
                    _riwayat.isEmpty
                        ? ListView(
                          children: const [
                            SizedBox(height: 300),
                            Center(
                              child: Text(
                                'Belum ada riwayat pemesanan.',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          ],
                        )
                        : ListView(
                          children: _riwayat.map(buildRiwayatCard).toList(),
                        ),
              ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
