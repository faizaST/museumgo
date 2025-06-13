import 'package:flutter/material.dart';

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
            padding: const EdgeInsets.all(12.0),
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
                      ElevatedButton(
                        onPressed: () => onVerifikasi(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Verifikasi'),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => onHapus(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Hapus'),
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
