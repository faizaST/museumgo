import 'package:flutter/material.dart';

class KonfirmasiPage extends StatefulWidget {
  final String namaPengunjung;
  final DateTime tanggalKunjungan;
  final int jumlahTiket;

  const KonfirmasiPage({
    super.key,
    required this.namaPengunjung,
    required this.tanggalKunjungan,
    required this.jumlahTiket,
  });

  @override
  State<KonfirmasiPage> createState() => _KonfirmasiPageState();
}

class _KonfirmasiPageState extends State<KonfirmasiPage> {
  static const int hargaTiketPerOrang = 50000;
  bool _isFileUploaded = false;
  int _selectedIndex = 0;

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushNamed(context, '/user_home');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/riwayat');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/profil');
    }
  }

  void _uploadBukti() {
    setState(() {
      _isFileUploaded = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Simulasi bukti pembayaran diupload')),
    );
  }

  void _submit() {
    if (!_isFileUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan unggah bukti pembayaran')),
      );
      return;
    }

    Navigator.popUntil(context, (route) => route.isFirst);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pesanan berhasil dikonfirmasi!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalBayar = widget.jumlahTiket * hargaTiketPerOrang;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Konfirmasi Pesanan'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              icon: Icons.person,
              label: 'Nama Pengunjung',
              value: widget.namaPengunjung,
            ),
            _buildInfoCard(
              icon: Icons.calendar_today,
              label: 'Tanggal Kunjungan',
              value:
                  widget.tanggalKunjungan
                      .toLocal()
                      .toIso8601String()
                      .split("T")
                      .first,
            ),
            _buildInfoCard(
              icon: Icons.confirmation_number,
              label: 'Jumlah Tiket',
              value: '${widget.jumlahTiket} Tiket',
            ),
            const SizedBox(height: 10),

            // Ganti bagian Total Bayar dengan container border hitam:
            Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total Bayar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Rp ${totalBayar.toString()}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Bagian rekening bank tanpa container border:
            Center(
              child: Column(
                children: const [
                  Text(
                    'Transfer ke Rekening',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Bank BCA',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'No. Rekening: 1234-5678-9012',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Atas Nama: MuseumGo',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Unggah Bukti Pembayaran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _uploadBukti,
              icon: const Icon(Icons.upload_file, color: Colors.black),
              label: Text(
                _isFileUploaded
                    ? 'Bukti sudah diupload'
                    : 'Unggah Bukti Pembayaran',
                style: const TextStyle(color: Colors.black),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black),
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 32),

            Center(
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text(
                  'Konfirmasi Pesanan',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.black),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


