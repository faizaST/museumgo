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

    // Masukkan data ke tabel 'users'
    final userData = UserModel(
      userId: user.id,
      name: name,
      email: email,
      role: 'user',
    );

    await _client.from('users').insert(userData.toMap());
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

  // Logout
  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
