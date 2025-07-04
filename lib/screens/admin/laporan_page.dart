import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  DateTime selectedDate = DateTime.now();

  final int totalPengunjung = 125;
  final int totalTiket = 98;
  final int totalPendapatan = 1500000;

  final List<Map<String, dynamic>> laporanDetail = [
    {'nama': 'Andi', 'tanggal': '2025-06-01', 'jumlah': 2, 'total': 50000},
    {'nama': 'Budi', 'tanggal': '2025-06-03', 'jumlah': 4, 'total': 100000},
    {'nama': 'Sari', 'tanggal': '2025-06-05', 'jumlah': 1, 'total': 25000},
  ];

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showMonthPicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String get bulanTahun =>
      DateFormat('MMMM yyyy', 'id_ID').format(selectedDate);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Laporan Pemesanan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Periode
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Periode: $bulanTahun',
                  style: const TextStyle(fontSize: 16),
                ),
                ElevatedButton.icon(
                  onPressed: () => _selectMonth(context),
                  icon: const Icon(Icons.date_range),
                  label: const Text('Pilih Bulan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Statistik
            _buildStatCard(
              Icons.people,
              'Total Pengunjung',
              '$totalPengunjung',
              Colors.blue,
            ),
            _buildStatCard(
              Icons.confirmation_num,
              'Tiket Terjual',
              '$totalTiket',
              Colors.green,
            ),
            _buildStatCard(
              Icons.attach_money,
              'Total Pendapatan',
              'Rp${NumberFormat("#,###", "id_ID").format(totalPendapatan)}',
              Colors.orange,
            ),

            const SizedBox(height: 24),
            Text('Detail Transaksi', style: textTheme.titleMedium),
            const SizedBox(height: 8),

            // Detail Transaksi
            Expanded(
              child: ListView.builder(
                itemCount: laporanDetail.length,
                itemBuilder: (context, index) {
                  final item = laporanDetail[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Text('${index + 1}'),
                      ),
                      title: Text('${item['nama']} - ${item['tanggal']}'),
                      subtitle: Text('${item['jumlah']} tiket'),
                      trailing: Text(
                        'Rp ${NumberFormat('#,###', 'id_ID').format(item['total'])}',
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Tombol Export
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Export PDF berhasil (simulasi).'),
                    ),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Export PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
