import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/pesan_model.dart';
import '../../services/pesan_service.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  final _service = PemesananService();
  final primaryColor = const Color(0xFF2563EB);
  DateTime selectedDate = DateTime.now();

  List<Tiket> laporan = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLaporan();
  }

  Future<void> _loadLaporan() async {
    setState(() => isLoading = true);

    final awal = DateTime(selectedDate.year, selectedDate.month, 1);
    final akhir = DateTime(selectedDate.year, selectedDate.month + 1, 0);

    try {
      final response = await _service.client
          .from('pemesanan')
          .select()
          .eq('status', 'Dikonfirmasi')
          .gte('tanggal', awal.toIso8601String())
          .lte('tanggal', akhir.toIso8601String());

      laporan =
          List<Map<String, dynamic>>.from(response).map((e) {
            return Tiket(
              userId: e['user_id'],
              nama: e['nama'],
              tanggal: e['tanggal'],
              jumlah: e['jumlah'],
              total: e['total'],
              buktiUrl: e['bukti_url'] ?? '',
              status: e['status'] ?? 'Menunggu',
            );
          }).toList();
    } catch (e) {
      print('❌ Gagal memuat laporan: $e');
    }

    setState(() => isLoading = false);
  }

  Future<void> _selectMonth(BuildContext context) async {
    final picked = await showMonthPicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
      await _loadLaporan();
    }
  }

  String get bulanTahun =>
      DateFormat('MMMM yyyy', 'id_ID').format(selectedDate);

  int get totalPengunjung => laporan.length;
  int get totalTiket => laporan.fold(0, (sum, item) => sum + item.jumlah);
  int get totalPendapatan => laporan.fold(0, (sum, item) => sum + item.total);

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
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: const Color.fromARGB(235, 228, 235, 252),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Periode: $bulanTahun',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2563EB),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _selectMonth(context),
                  icon: const Icon(Icons.date_range),
                  label: const Text('Pilih Bulan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
              'Rp ${NumberFormat("#,###", "id_ID").format(totalPendapatan)}',
              Colors.orange,
            ),
            const SizedBox(height: 24),
            Text('Detail Transaksi', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : laporan.isEmpty
                      ? const Center(child: Text('Tidak ada transaksi.'))
                      : ListView.builder(
                        itemCount: laporan.length,
                        itemBuilder: (context, index) {
                          final item = laporan[index];
                          return Card(
                            color: Colors.white, // <-- agar putih
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            elevation: 2,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: primaryColor.withOpacity(0.1),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(color: primaryColor),
                                ),
                              ),
                              title: Text('${item.nama} - ${item.tanggal}'),
                              subtitle: Text('${item.jumlah} tiket'),
                              trailing: Text(
                                'Rp ${NumberFormat('#,###', 'id_ID').format(item.total)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton.icon(
                onPressed: _exportPDF,
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
      color: Colors.white, // <-- warna putih
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

  Future<void> _exportPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        build:
            (context) => [
              pw.Text(
                'Laporan Pemesanan - $bulanTahun',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Text('Total Pengunjung: $totalPengunjung'),
              pw.Text('Total Tiket Terjual: $totalTiket'),
              pw.Text(
                'Total Pendapatan: Rp ${NumberFormat("#,###", "id_ID").format(totalPendapatan)}',
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Detail Transaksi',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              ...laporan.map((item) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Text(
                    '${item.nama} | ${item.tanggal} | ${item.jumlah} tiket | Rp ${NumberFormat("#,###", "id_ID").format(item.total)}',
                  ),
                );
              }),
            ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
