import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final _box = GetStorage();
  bool _isUploading = false;
  String? _uploadedImageUrl;
  XFile? _imageFile;

  Future<void> _pickImageAndUpload() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _isUploading = true);

      try {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
        final fileBytes = await pickedFile.readAsBytes();

        // Upload ke Supabase Storage
        await Supabase.instance.client.storage
            .from('bukti-pembayaran')
            .uploadBinary('bukti_url/$fileName', fileBytes);

        final publicUrl = Supabase.instance.client.storage
            .from('bukti-pembayaran')
            .getPublicUrl('bukti_url/$fileName');

        setState(() {
          _imageFile = pickedFile;
          _uploadedImageUrl = publicUrl;
        });

        print('✅ Upload berhasil. Public URL: $_uploadedImageUrl');

        Get.snackbar(
          'Upload Berhasil',
          'Bukti pembayaran berhasil diunggah',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        print('❌ Upload error: $e');
        Get.snackbar(
          'Upload Gagal',
          'Terjadi kesalahan: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _submit() async {
    if (_uploadedImageUrl == null) {
      Get.snackbar(
        'Error',
        'Silakan unggah bukti pembayaran',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

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

    final userId = user.id;
    final totalBayar = widget.jumlahTiket * hargaTiketPerOrang;

    final pemesananData = {
      'user_id': userId,
      'nama': widget.namaPengunjung,
      'tanggal': widget.tanggalKunjungan.toIso8601String().substring(0, 10),
      'jumlah': widget.jumlahTiket,
      'total': totalBayar,
      'bukti_url': _uploadedImageUrl,
    };

    try {
      final response =
          await Supabase.instance.client
              .from('pemesanan')
              .insert(pemesananData)
              .select()
              .single();

      print('✅ Insert response: $response');

      _box.write('last_konfirmasi', response);

      Get.offAllNamed('/riwayat');

      Get.snackbar(
        'Sukses',
        'Pesanan berhasil dikonfirmasi!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Insert error: $e');
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan saat menyimpan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalBayar = widget.jumlahTiket * hargaTiketPerOrang;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pesan Tiket'),
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
            _buildInfoBox(
              label: 'Nama Pengunjung',
              value: widget.namaPengunjung,
            ),
            _buildInfoBox(
              label: 'Tanggal Kunjungan',
              value: widget.tanggalKunjungan.toIso8601String().substring(0, 10),
            ),
            _buildInfoBox(
              label: 'Jumlah Tiket',
              value: '${widget.jumlahTiket}',
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    'Total yang harus dibayar:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp $totalBayar',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: const [
                  Text(
                    'Silakan transfer ke:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text('BCA - 1234567890 a.n. MuseumGo'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Unggah Bukti Pembayaran',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _isUploading ? null : _pickImageAndUpload,
              icon: const Icon(Icons.upload_file, color: Colors.black),
              label: Text(
                _isUploading
                    ? 'Mengunggah...'
                    : (_uploadedImageUrl != null
                        ? 'Bukti sudah diupload'
                        : 'Unggah Bukti Pembayaran'),
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
                onPressed: _isUploading ? null : _submit,
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox({required String label, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
