import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utama/screens/auth/login_page.dart';

class SplashscreenPage extends StatefulWidget {
  const SplashscreenPage({super.key});

  @override
  State<SplashscreenPage> createState() => _SplashscreenPageState();
}

class _SplashscreenPageState extends State<SplashscreenPage>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _loaderController;

  late Animation<double> _logoFade;
  late Animation<double> _loaderFade;

  @override
  void initState() {
    super.initState();

    // Animasi logo
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(_logoController);

    // Animasi loader
    _loaderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _loaderFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_loaderController);

    logoController.forward().then(() {
      Future.delayed(const Duration(milliseconds: 300), () {
        _loaderController.forward();
      });
    });

    // Navigasi otomatis ke LoginPage
    Timer(const Duration(milliseconds: 2500), () {
      Get.off(() => const LoginPage());
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _loaderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: _logoFade,
              child: Image.asset(
                'assets/images/splash.png',
                width: 130,
                height: 130,
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _loaderFade,
              child: const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFF2563EB), // Biru khas MuseumGo
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}