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
  final primaryColor = const Color(0xFF2563EB);

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
          .select('user_id, name, email, role, is_blocked');

      List<Map<String, dynamic>> result = [];

      for (var user in users) {
        final userId = user['user_id'];
        if (user['role'] != 'user') continue;

        final tiketData = await client
            .from('pemesanan')
            .select('jumlah')
            .eq('user_id', userId);

        int totalTiket = 0;
        for (var item in tiketData) {
          final jumlah = item['jumlah'];
          final parsed = int.tryParse(jumlah.toString()) ?? 0;
          totalTiket += parsed;
        }

        result.add({
          "id": userId,
          "nama": user['name'] ?? '-',
          "email": user['email'] ?? '-',
          "jumlahTiket": totalTiket,
          "isBlocked": user['is_blocked'] ?? false,
        });
      }

      setState(() {
        penggunaList = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar("Error", "Gagal memuat data: $e");
    }
  }

  Future<void> blokirPengguna(String userId, String nama, bool blokir) async {
    try {
      await client
          .from('users')
          .update({'is_blocked': blokir})
          .eq('user_id', userId);

      final statusText = blokir ? 'diblokir' : 'dibuka blokirnya';
      Get.snackbar("Berhasil", "Pengguna $nama $statusText");

      setState(() {
        final index = penggunaList.indexWhere((user) => user['id'] == userId);
        if (index != -1) {
          penggunaList[index]['isBlocked'] = blokir;
        }
      });
    } catch (e) {
      Get.snackbar("Error", "Gagal update status: $e");
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
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Color.fromARGB(235, 228, 235, 252), // Biru muda lembut
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : penggunaList.isEmpty
                ? const Center(child: Text("Tidak ada pengguna."))
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: penggunaList.length,
                  itemBuilder: (context, index) {
                    final user = penggunaList[index];
                    final isBlocked = user['isBlocked'] == true;

                    return Card(
                      color: isBlocked ? Colors.grey.shade200 : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Icon(
                          Icons.person,
                          color: isBlocked ? Colors.grey : primaryColor,
                        ),
                        title: Text(
                          user['nama'],
                          style: TextStyle(
                            color: isBlocked ? Colors.grey : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['email'],
                              style: TextStyle(
                                color:
                                    isBlocked ? Colors.grey : Colors.grey[800],
                              ),
                            ),
                            Text(
                              'Tiket dibeli: ${user['jumlahTiket']}',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isBlocked
                                        ? Colors.grey
                                        : Colors.grey.shade600,
                              ),
                            ),
                            if (isBlocked)
                              const Text(
                                'Status: Diblokir',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Get.defaultDialog(
                              title: 'Konfirmasi',
                              middleText:
                                  isBlocked
                                      ? 'Buka blokir pengguna ${user['nama']}?'
                                      : 'Blokir pengguna ${user['nama']}?',
                              textCancel: 'Batal',
                              textConfirm: isBlocked ? 'Buka Blokir' : 'Blokir',
                              confirmTextColor: Colors.white,
                              onConfirm: () {
                                Get.back();
                                blokirPengguna(
                                  user['id'],
                                  user['nama'],
                                  !isBlocked,
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isBlocked ? Colors.green : Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(isBlocked ? 'Buka Blokir' : 'Blokir'),
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
