import 'package:flutter/material.dart';

class PenggunaPage extends StatefulWidget {
  const PenggunaPage({super.key});

  @override
  State<PenggunaPage> createState() => _PenggunaPageState();
}

class _PenggunaPageState extends State<PenggunaPage> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> penggunaList = [
      {"nama": "Ayu Setiawan", "email": "ayu@gmail.com", "jumlahTiket": 3},
      {"nama": "Budi Hartono", "email": "budi@gmail.com", "jumlahTiket": 5},
      {"nama": "Citra Larasati", "email": "citra@gmail.com", "jumlahTiket": 2},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Data Pengguna',
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
      body: ListView.builder(
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
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Konfirmasi'),
                          content: Text('Blokir pengguna ${user['nama']}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Pengguna ${user['nama']} diblokir.',
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'Blokir',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
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
