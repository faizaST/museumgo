import 'package:supabase_flutter/supabase_flutter.dart';

class PemesananService {
  final _client = Supabase.instance.client;

  Future<void> simpanPemesanan(Map<String, dynamic> data) async {
    await _client.from('pemesanan').insert(data);
  }

  Future<List<Map<String, dynamic>>> ambilPemesananUser(String userId) async {
    final response = await _client
        .from('pemesanan')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }
}
