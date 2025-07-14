import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'konfirmasi_page.dart';

class PesanPage extends StatefulWidget {
  const PesanPage({super.key});

  @override
  State<PesanPage> createState() => _PesanPageState();
}

class _PesanPageState extends State<PesanPage> {
  final _box = GetStorage();

  DateTime? _tanggalKunjungan;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _jumlahTiketController = TextEditingController(
    text: '1',
  );

  int _stokTiket = 0;

  void _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalKunjungan ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _tanggalKunjungan = picked;
        _tanggalController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
      _cekStok(picked);
    }
  }

  void _cekStok(DateTime tanggal) {
    final key = 'stok_${tanggal.toIso8601String().substring(0, 10)}';
    final stok = _box.read(key) ?? 100;
    setState(() => _stokTiket = stok);
  }

  void _submitPesanan() {
    if (_namaController.text.isEmpty || _tanggalKunjungan == null) {
      Get.snackbar(
        'Error',
        'Semua data wajib diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final jumlah = int.tryParse(_jumlahTiketController.text) ?? 1;
    if (jumlah > _stokTiket) {
      Get.snackbar(
        'Stok Tidak Cukup',
        'Sisa tiket: $_stokTiket',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final key = 'stok_${_tanggalKunjungan!.toIso8601String().substring(0, 10)}';
    _box.write(key, _stokTiket - jumlah);

    Get.to(
      () => KonfirmasiPage(
        namaPengunjung: _namaController.text,
        tanggalKunjungan: _tanggalKunjungan!,
        jumlahTiket: jumlah,
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _tanggalController.dispose();
    _jumlahTiketController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesan Tiket')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Pengunjung',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tanggalController,
              readOnly: true,
              onTap: _pilihTanggal,
              decoration: const InputDecoration(
                labelText: 'Tanggal Kunjungan',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 8),
            if (_tanggalKunjungan != null)
              Text(
                'Stok tiket tersedia: $_stokTiket',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _jumlahTiketController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Tiket',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitPesanan,
              child: const Text('Pesan Tiket'),
            ),
          ],
        ),
      ),
    );
  }
}