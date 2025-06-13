import 'package:flutter/material.dart';
import 'pemesanan_body_page.dart';

class PemesananPage extends StatefulWidget {
  const PemesananPage({super.key});

  @override
  State<PemesananPage> createState() => _PemesananPageState();
}

class _PemesananPageState extends State<PemesananPage> {
  List<Map<String, dynamic>> pemesananList = [
    {
      "nama": "Ayu Setiawan",
      "tanggal": "7 Juni 2025",
      "jumlahTiket": 2,
      "status": "Menunggu",
    },
    {
      "nama": "Budi Hartono",
      "tanggal": "6 Juni 2025",
      "jumlahTiket": 4,
      "status": "Terverifikasi",
    },
    {
      "nama": "Citra Larasati",
      "tanggal": "5 Juni 2025",
      "jumlahTiket": 1,
      "status": "Menunggu",
    },
  ];

  void verifikasi(int index) {
    setState(() {
      pemesananList[index]['status'] = 'Terverifikasi';
    });
  }

  void hapus(int index) {
    setState(() {
      pemesananList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PemesananBody(
      pemesananList: pemesananList,
      onVerifikasi: verifikasi,
      onHapus: hapus,
    );
  }
}
