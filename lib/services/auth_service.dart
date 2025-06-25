import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final _client = Supabase.instance.client;

  // Register User
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
      });
    } else {
      // Update name kalau sudah ada
      await _client.from('users').update({'name': name}).eq('user_id', user.id);
    }
  }

  // Login User
  Future<UserModel> loginUser({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) throw AuthException("Login gagal");

    final data =
        await _client.from('users').select().eq('user_id', user.id).single();

    return UserModel.fromMap(data);
  }

  // Get current logged-in user's profile
  Future<UserModel?> getCurrentUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final data =
        await _client.from('users').select().eq('user_id', user.id).single();

    return UserModel.fromMap(data);
  }

  // Logout
  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
