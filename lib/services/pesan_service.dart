import 'package:supabase_flutter/supabase_flutter.dart';

class PemesananService {
  final _client = Supabase.instance.client;

  SupabaseClient get client => _client;

  // Simpan data pemesanan ke tabel 'pemesanan'
  Future<void> simpanPemesanan(Map<String, dynamic> data) async {
    await _client.from('pemesanan').insert({
      ...data,
      'status': data['status'] ?? 'Menunggu',
    });
  }

  // Ambil data pemesanan untuk user tertentu
  Future<List<Map<String, dynamic>>> ambilPemesananUser(String userId) async {
    final response = await _client
        .from('pemesanan')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // ✅ Ambil semua data pemesanan (untuk admin)
  Future<List<Map<String, dynamic>>> ambilSemuaPemesanan() async {
    final response = await _client
        .from('pemesanan')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // ✅ Konfirmasi pesanan
  Future<void> konfirmasiPemesanan(String id) async {
    await _client
        .from('pemesanan')
        .update({'status': 'Dikonfirmasi'})
        .eq('id', id);
  }

  // ✅ Tolak pesanan
  Future<void> tolakPemesanan(String id) async {
    await _client.from('pemesanan').update({'status': 'Ditolak'}).eq('id', id);
  }

  // ✅ Hapus pesanan
  Future<void> hapusPemesanan(String id) async {
    await _client.from('pemesanan').delete().eq('id', id);
  }
}
