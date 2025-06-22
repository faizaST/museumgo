import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/auth_service.dart';
import 'login_page.dart';

class RegistrasiPage extends StatefulWidget {
  const RegistrasiPage({super.key});

  @override
  State<RegistrasiPage> createState() => _RegistrasiPageState();
}

class _RegistrasiPageState extends State<RegistrasiPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  String? name;
  String? email;
  String? password;
  String? confirmPassword;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        await _authService.registerUser(
          name: name!,
          email: email!,
          password: password!,
        );

        Get.snackbar(
          "Registrasi Berhasil",
          "Silakan login terlebih dahulu",
          snackPosition: SnackPosition.BOTTOM,
        );

        Get.off(() => const LoginPage());
      } catch (e) {
        Get.snackbar(
          "Error",
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrasi'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Nama wajib diisi'
                            : null,
                onSaved: (value) => name = value,
              ),
              const SizedBox(height: 16),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password wajib diisi';
                  }
                  if (value.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
                onChanged: (value) => password = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed:
                        () => setState(
                          () =>
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                        ),
                  ),
                ),
                obscureText: _obscureConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi password wajib diisi';
                  }
                  if (value != password) {
                    return 'Password tidak cocok';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Daftar', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sudah punya akun? '),
                  GestureDetector(
                    onTap: () => Get.off(() => const LoginPage()),
                    child: const Text(
                      'Login',
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
