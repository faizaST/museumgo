import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;

  String? email;
  String? password;

  void _submitLogin() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Proses login
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login berhasil')));

      // Contoh pindah ke dashboard (ganti sesuai kebutuhan)
      // Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 32),
              Text(
                "Selamat Datang!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),

              // Email (tanpa icon)
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email wajib diisi';
                  }
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(value)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
                onSaved: (value) => email = value,
              ),
              SizedBox(height: 16),

              // Password (tanpa icon)
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password wajib diisi';
                  }
                  return null;
                },
                onSaved: (value) => password = value,
              ),
              SizedBox(height: 24),

              //ElevatedButton(
                //onPressed: () {
                  //Navigator.push(
                    //context,
                    //MaterialPageRoute(builder: (context) => UserHomePage()),
                  //);
                //},
                //child: Text("Login"),
              //),

              // Tombol Login
              //ElevatedButton(
              //onPressed: _submitLogin,
              //style: ElevatedButton.styleFrom(
              //padding: EdgeInsets.symmetric(vertical: 14),
              //),
              //child: Text('Login', style: TextStyle(fontSize: 18)),
              //),
              SizedBox(height: 16),

              // Link ke Registrasi
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Belum punya akun? "),
                  GestureDetector(
                    onTap: () {
                      //Navigator.push(
                        //context,
                        //MaterialPageRoute(
                          //builder: (context) => RegistrasiPage(),
                        //),
                      //);
                    },
                    child: Text(
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
