import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final _client = Supabase.instance.client;

  // 🔐 Register User
  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) throw Exception("Registrasi gagal");

    // Cek apakah user_id sudah ada di tabel users
    final existing =
        await _client
            .from('users')
            .select()
            .eq('user_id', user.id)
            .maybeSingle();

    if (existing == null) {
      // Insert jika belum ada
      await _client.from('users').insert({
        'user_id': user.id,
        'name': name,
        'email': email,
        'role': 'user',
        'is_blocked': false, // default tidak diblokir
      });
    } else {
      // Update name kalau sudah ada
      await _client.from('users').update({'name': name}).eq('user_id', user.id);
    }
  }

  // 🔐 Login User dengan cek blokir
  Future<UserModel> loginUser({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) throw AuthException("Login gagal: akun tidak ditemukan");

    // Ambil data pengguna dari tabel 'users'
    final data =
        await _client.from('users').select().eq('user_id', user.id).single();

    // ❌ Blokir pengguna jika is_blocked = true
    if (data['is_blocked'] == true) {
      await _client.auth.signOut(); // Paksa logout
      throw AuthException("Akun Anda telah diblokir. Hubungi admin.");
    }

    // ✅ Return userModel jika tidak diblokir
    return UserModel.fromMap(data);
  }

  // 🔄 Ambil profile pengguna aktif
  Future<UserModel?> getCurrentUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final data =
        await _client.from('users').select().eq('user_id', user.id).single();

    return UserModel.fromMap(data);
  }

  // 🚪 Logout
  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
