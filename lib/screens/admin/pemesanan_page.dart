import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PemesananFullPage extends StatelessWidget {
  const PemesananFullPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SafeArea(child: PemesananPage()));
  }
}

class PemesananPage extends StatefulWidget {
  const PemesananPage({super.key});

  @override
  State<PemesananPage> createState() => _PemesananPageState();
}

class _PemesananPageState extends State<PemesananPage> {
  List<Map<String, dynamic>> pemesananList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    ambilPemesanan();
  }

  Future<void> ambilPemesanan() async {
    final response = await Supabase.instance.client
        .from('pemesanan')
        .select()
        .order('created_at', ascending: false);

    setState(() {
      pemesananList = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
  }

  Future<void> verifikasi(int index) async {
    final id = pemesananList[index]['id'];
    try {
      await Supabase.instance.client
          .from('pemesanan')
          .update({'status': 'Dikonfirmasi'})
          .eq('id', id);
      await ambilPemesanan();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pemesanan telah dikonfirmasi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal konfirmasi: $e')));
    }
  }

  Future<void> tolak(int index) async {
    final id = pemesananList[index]['id'];
    try {
      await Supabase.instance.client
          .from('pemesanan')
          .update({'status': 'Ditolak'})
          .eq('id', id);
      await ambilPemesanan();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pemesanan telah ditolak')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal tolak: $e')));
    }
  }

  Future<void> hapus(int index) async {
    final id = pemesananList[index]['id'];
    final nama = pemesananList[index]['nama'];
    await Supabase.instance.client.from('pemesanan').delete().eq('id', id);
    await ambilPemesanan();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Pemesanan $nama dihapus')));
  }

  Future<void> bukaBukti(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka bukti pembayaran')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : pemesananList.isEmpty
              ? const Center(child: Text('Belum ada data pemesanan.'))
              : PemesananBody(
                pemesananList: pemesananList,
                onVerifikasi: verifikasi,
                onTolak: tolak,
                onHapus: hapus,
                onBukaBukti: bukaBukti,
              ),
    );
  }
}

class PemesananBody extends StatelessWidget {
  final List<Map<String, dynamic>> pemesananList;
  final void Function(int) onVerifikasi;
  final void Function(int) onTolak;
  final void Function(int) onHapus;
  final void Function(String) onBukaBukti;

  const PemesananBody({
    super.key,
    required this.pemesananList,
    required this.onVerifikasi,
    required this.onTolak,
    required this.onHapus,
    required this.onBukaBukti,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pemesananList.length,
      itemBuilder: (context, index) {
        final item = pemesananList[index];
        final status = item['status'] ?? 'Menunggu Konfirmasi';
        final isConfirmed = status == 'Dikonfirmasi';
        final isRejected = status == 'Ditolak';
        final buktiUrl = item['bukti_url'] ?? '';

        Color statusColor = Colors.orange;
        if (isConfirmed) statusColor = Colors.green;
        if (isRejected) statusColor = Colors.red;

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
                Row(
                  children: [
                    const Icon(Icons.person, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      item['nama'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 8),
                    Text('Tanggal: ${item['tanggal']}'),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.confirmation_num, size: 18),
                    const SizedBox(width: 8),
                    Text('Jumlah Tiket: ${item['jumlah']}'),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.verified, size: 18, color: statusColor),
                    const SizedBox(width: 8),
                    Text(
                      'Status: $status',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (buktiUrl.isNotEmpty)
                  InkWell(
                    onTap: () => onBukaBukti(buktiUrl),
                    child: Row(
                      children: const [
                        Icon(Icons.receipt_long, color: Colors.blue),
                        SizedBox(width: 6),
                        Text(
                          'Lihat Bukti Pembayaran',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isConfirmed && !isRejected)
                      ElevatedButton.icon(
                        onPressed: () => onVerifikasi(index),
                        icon: const Icon(Icons.check),
                        label: const Text('Konfirmasi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    const SizedBox(width: 8),
                    if (!isConfirmed && !isRejected)
                      ElevatedButton.icon(
                        onPressed: () => onTolak(index),
                        icon: const Icon(Icons.close),
                        label: const Text('Tolak'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
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
