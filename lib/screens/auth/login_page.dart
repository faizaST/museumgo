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

        // Simpan session
        _box.write('user_id', userModel.userId);
        _box.write('role', userModel.role);

        Get.snackbar(
          "Login Berhasil",
          "Selamat datang ${userModel.name}!",
          snackPosition: SnackPosition.BOTTOM,
        );

        // Navigasi sesuai role
        if (userModel.role == 'admin') {
          Get.offAll(() => const AdminHomePage());
        } else {
          Get.offAll(() => const UserHomePage());
        }
      } catch (e) {
        Get.snackbar(
          "Login Gagal",
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 32),
              const Text(
                "Selamat Datang!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
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
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
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
              ElevatedButton(
                onPressed: isLoading ? null : _submitLogin,
                child:
                    isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Login"),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Belum punya akun? "),
                  GestureDetector(
                    onTap: () => Get.to(() => const RegistrasiPage()),
                    child: const Text(
                      "Daftar sekarang",
                      style: TextStyle(
                        color: Colors.blue,
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
    );
  }
}
