import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('pemesanan')
        .select()
        .order('created_at', ascending: false);

    final List<Map<String, dynamic>> updatedList = [];

    for (final data in response) {
      updatedList.add({
        ...data,
        'bukti_url_public': data['bukti_url'], // asumsi sudah full URL
      });
    }

    setState(() {
      pemesananList = updatedList;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4EBFC),
      body: SafeArea(
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : pemesananList.isEmpty
                ? const Center(child: Text('Belum ada data pemesanan.'))
                : PemesananBody(
                  pemesananList: pemesananList,
                  onVerifikasi: verifikasi,
                  onTolak: tolak,
                  onHapus: hapus,
                ),
      ),
    );
  }
}

class PemesananBody extends StatelessWidget {
  final List<Map<String, dynamic>> pemesananList;
  final void Function(int) onVerifikasi;
  final void Function(int) onTolak;
  final void Function(int) onHapus;

  const PemesananBody({
    super.key,
    required this.pemesananList,
    required this.onVerifikasi,
    required this.onTolak,
    required this.onHapus,
  });

  void showBuktiDialog(BuildContext context, String buktiUrl) {
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
                    child: Image.network(
                      buktiUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text(
                            'Gagal memuat gambar bukti pembayaran',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }

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
        final buktiUrl = item['bukti_url_public'] ?? '';

        Color statusColor = Colors.orange;
        if (isConfirmed) statusColor = Colors.green;
        if (isRejected) statusColor = Colors.red;

        return Card(
          color: Colors.white,
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
                      item['nama'] ?? '',
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
                    onTap: () => showBuktiDialog(context, buktiUrl),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long, color: Colors.blue, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Lihat Bukti Pembayaran',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    if (!isConfirmed && !isRejected)
                      ElevatedButton.icon(
                        onPressed: () => onVerifikasi(index),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text(
                          'Konfirmasi',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(100, 32),
                        ),
                      ),
                    if (!isConfirmed && !isRejected)
                      ElevatedButton.icon(
                        onPressed: () => onTolak(index),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text(
                          'Tolak',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(80, 32),
                        ),
                      ),
                    ElevatedButton.icon(
                      onPressed: () => onHapus(index),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text(
                        'Hapus',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, 32),
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
