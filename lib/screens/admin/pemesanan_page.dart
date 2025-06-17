import 'package:flutter/material.dart';

class PemesananFullPage extends StatelessWidget {
  const PemesananFullPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Pemesanan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: const SafeArea(child: PemesananPage()),
    );
  }
}

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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pemesanan telah diverifikasi')),
    );
  }

  void hapus(int index) {
    final nama = pemesananList[index]['nama'];
    setState(() {
      pemesananList.removeAt(index);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Pemesanan $nama dihapus')));
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

class PemesananBody extends StatelessWidget {
  final List<Map<String, dynamic>> pemesananList;
  final void Function(int) onVerifikasi;
  final void Function(int) onHapus;

  const PemesananBody({
    super.key,
    required this.pemesananList,
    required this.onVerifikasi,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pemesananList.length,
      itemBuilder: (context, index) {
        final item = pemesananList[index];

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '👤 ${item['nama']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('📅 Tanggal: ${item['tanggal']}'),
                Text('🎟️ Jumlah Tiket: ${item['jumlahTiket']}'),
                Text(
                  '📌 Status: ${item['status']}',
                  style: TextStyle(
                    color:
                        item['status'] == 'Terverifikasi'
                            ? Colors.green
                            : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (item['status'] != 'Terverifikasi')
                      ElevatedButton.icon(
                        onPressed: () => onVerifikasi(index),
                        icon: const Icon(Icons.check),
                        label: const Text('Verifikasi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => onHapus(index),
                      icon: const Icon(Icons.delete),
                      label: const Text('Hapus'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
