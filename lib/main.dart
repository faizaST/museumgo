import 'package:flutter/material.dart';
import 'package:museumgo/screens/auth/login_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:museumgo/screens/auth/registrasi_page.dart';
import 'package:museumgo/screens/admin/admin_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Wajib sebelum async init
  await initializeDateFormatting('id_ID', null); // Inisialisasi lokal Indonesia

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routes: {
        '/screens/auth/login_screen': (context) => LoginPage(),
        '/screens/auth/registrasi_screen': (context) => RegistrasiPage(),
        // Tambahkan rute lainnya sesuai kebutuhan
      },
      home: AdminHomePage(),
    );
  }
}
