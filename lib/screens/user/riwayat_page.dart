import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final PemesananService _pemesananService = PemesananService();
  final String userId = Supabase.instance.client.auth.currentUser!.id;
  final Color primaryColor = const Color(0xFF2563EB);
  List<Tiket> daftarPemesanan = [];

  @override
  void initState() {
    super.initState();
    ambilData();
  }

  Future<void> ambilData() async {
    final data = await _pemesananService.ambilPemesananUser(userId);
    setState(() {
      daftarPemesanan =
          data
              .map(
                (item) => Tiket(
                  userId: item['user_id'],
                  nama: item['nama'],
                  tanggal: item['tanggal'],
                  jumlah: item['jumlah'],
                  total: item['total'],
                  buktiUrl: item['bukti_url'],
                  status: item['status'],
                ),
              )
              .toList();
    });
  }

  void showBuktiDialog(String buktiUrl) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: InteractiveViewer(
                child: Container(
                  constraints: const BoxConstraints(
                    maxHeight: 300,
                    maxWidth: 300,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(buktiUrl, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget statusWarna(String status) {
    if (status.toLowerCase() == "dikonfirmasi") {
      return const Text(
        "Status: Dikonfirmasi",
        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      );
    } else {
      return const Text(
        "Status: Menunggu Konfirmasi",
        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Pemesanan"),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.off(() => const home.UserHomePage()),
        ),
      ),
      body: ListView.builder(
        itemCount: daftarPemesanan.length,
        padding: const EdgeInsets.all(10),
        itemBuilder: (context, index) {
          final tiket = daftarPemesanan[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue.shade300),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kiri: Info Tiket
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tiket.nama,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text("Tanggal: ${tiket.tanggal}"),
                      Text("Jumlah Tiket: ${tiket.jumlah}"),
                      Text("Total Bayar: Rp ${tiket.total}"),
                      const SizedBox(height: 4),
                      statusWarna(tiket.status),
                    ],
                  ),
                ),
                // Kanan: Tombol Bukti
                if (tiket.buktiUrl.isNotEmpty)
                  IconButton(
                    icon: const Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.blue,
                    ),
                    tooltip: "Lihat Bukti",
                    onPressed: () => showBuktiDialog(tiket.buktiUrl),
                  ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Get.off(() => const home.UserHomePage());
          } else if (index == 2) {
            Get.off(() => const ProfilPage());
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Riwayat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}
