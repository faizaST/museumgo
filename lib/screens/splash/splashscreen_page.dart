import 'package:flutter/material.dart';
import 'dart:async';
//import 'package:utama/screens/auth/login_page.dart';

class SplashscreenPage extends StatefulWidget {
  const SplashscreenPage({super.key});

  @override
  State<SplashscreenPage> createState() => _SplashscreenPageState();
}

class _SplashscreenPageState extends State<SplashscreenPage> {
  @override
  void initState() {
    super.initState();

    // Delay 2 detik, lalu pindah ke halaman login
    Timer(const Duration(seconds: 2), () {
      //Navigator.push(
        //context,
        //MaterialPageRoute(builder: (context) => LoginPage()),
      //);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Warna latar
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ganti dengan logo asli jika sudah ada di assets/
            const Text("Logo", style: TextStyle(fontSize: 32)),
            const SizedBox(height: 20),
            const Text(
              "MuseumGo",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
