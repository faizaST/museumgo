import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PenggunaPage extends StatefulWidget {
  const PenggunaPage({super.key});

  @override
  State<PenggunaPage> createState() => _PenggunaPageState();
}

class _PenggunaPageState extends State<PenggunaPage> {
  final client = Supabase.instance.client;
  List<Map<String, dynamic>> penggunaList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPenggunaData();
  }

  Future<void> fetchPenggunaData() async {
    try {
      final users = await client
          .from('users')
          .select('user_id, name, email, role');

      List<Map<String, dynamic>> result = [];

      for (var user in users) {
        final userId = user['user_id'];
        if (user['role'] != 'user') continue;

        print('👤 Pengguna: ${user['name']} ($userId)');

        final tiketData = await client
            .from('pemesanan')
            .select('jumlah')
            .eq('user_id', userId);

        print('🎟️ Tiket ditemukan: $tiketData');

        int totalTiket = 0;
        for (var item in tiketData) {
          final jumlah = item['jumlah'];
          final parsed = int.tryParse(jumlah.toString()) ?? 0;
          totalTiket += parsed;
        }

        print('✅ Total Tiket ${user['name']}: $totalTiket');

        result.add({
          "id": userId,
          "nama": user['name'] ?? '-',
          "email": user['email'] ?? '-',
          "jumlahTiket": totalTiket,
        });
      }

      setState(() {
        penggunaList = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("❌ ERROR FETCH: $e");
      Get.snackbar("Error", "Gagal memuat data: $e");
    }
  }

  Future<void> blokirPengguna(String userId, String nama) async {
    try {
      await client
          .from('users')
          .update({'is_blocked': true})
          .eq('user_id', userId);

      Get.snackbar("Berhasil", "Pengguna $nama diblokir");
      fetchPenggunaData();
    } catch (e) {
      Get.snackbar("Error", "Gagal blokir pengguna: $e");
      print("ERROR BLOKIR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Data Pengguna',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : penggunaList.isEmpty
              ? const Center(child: Text("Tidak ada pengguna."))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: penggunaList.length,
                itemBuilder: (context, index) {
                  final user = penggunaList[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.person, color: Colors.blue),
                      title: Text(user['nama']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user['email']),
                          const SizedBox(height: 4),
                          Text(
                            'Tiket dibeli: ${user['jumlahTiket']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Get.defaultDialog(
                            title: 'Konfirmasi',
                            middleText: 'Blokir pengguna ${user['nama']}?',
                            textCancel: 'Batal',
                            textConfirm: 'Blokir',
                            confirmTextColor: Colors.white,
                            onConfirm: () {
                              Get.back();
                              blokirPengguna(user['id'], user['nama']);
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Blokir'),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
