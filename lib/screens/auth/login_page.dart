import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../services/auth_service.dart';
import '../admin/admin_home_page.dart';
import '../user/user_home_page.dart';
import 'registrasi_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _box = GetStorage();

  bool _obscurePassword = true;
  String? email;
  String? password;
  bool isLoading = false;

  Future<void> _submitLogin() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => isLoading = true);

      try {
        final userModel = await _authService.loginUser(
          email: email!,
          password: password!,
        );

        _box.write('user_id', userModel.userId);
        _box.write('role', userModel.role);

        Get.snackbar(
          "Login Berhasil",
          "Selamat datang ${userModel.name}!",
          snackPosition: SnackPosition.BOTTOM,
        );

        if (userModel.role == 'admin') {
          Get.offAll(() => const AdminHomePage());
        } else {
          Get.offAll(() => const UserHomePage());
        }
      } catch (e) {
        String message = e.toString();

        if (message.contains('invalid_credentials')) {
          message = "Gagal Login: Email atau Password salah";
        } else if (message.contains('Akun Anda telah diblokir')) {
          message = "Gagal Login: Akun Anda telah diblokir";
        } else if (message.contains('user not found') ||
            message.contains('No row')) {
          message = "Gagal Login: Akun tidak terdaftar";
        } else {
          message = "Gagal Login: ${e.toString()}";
        }

        Get.snackbar(
          "Login Gagal",
          message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3B82F6);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(Icons.login, size: 80, color: primaryColor),
                const SizedBox(height: 16),
                const Text(
                  "MuseumGo",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Masuk ke akun Anda",
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 32),

                // Email
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: primaryColor),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: primaryColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Email wajib diisi'
                              : null,
                  onSaved: (value) => email = value,
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: primaryColor),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: primaryColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: primaryColor,
                      ),
                      onPressed:
                          () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Password wajib diisi'
                              : null,
                  onSaved: (value) => password = value,
                ),
                const SizedBox(height: 24),

                // Tombol Login
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: isLoading ? null : _submitLogin,
                    child:
                        isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 16),

                // Navigasi ke Registrasi
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Belum punya akun?",
                      style: TextStyle(color: Colors.black87),
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => const RegistrasiPage()),
                      child: const Text(
                        "Daftar sekarang",
                        style: TextStyle(
                          color: primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
