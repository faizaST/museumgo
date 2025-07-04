import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:museumgo/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init(); // Inisialisasi penyimpanan lokal
  await initializeDateFormatting(
    'id_ID',
    null,
  ); // Format tanggal lokal Indonesia

  await Supabase.initialize(
    url:
        'https://bydjzlkudumkqqswfglh.supabase.co', // Ganti dengan project Supabase kamu
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ5ZGp6bGt1ZHVta3Fxc3dmZ2xoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA1OTQzOTEsImV4cCI6MjA2NjE3MDM5MX0.JKsYo86nES8jGnJOpbW5qMe0gAK7f9zAo3-ZihN8uo4', // Ganti juga dengan anon key kamu
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'UTAMA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      initialRoute: AppPages.initialRoute,
      getPages: AppPages.routes,
    );
  }
}
