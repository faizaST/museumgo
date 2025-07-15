import 'package:get/get.dart';
import 'package:museumgo/screens/splash/splashscreen_page.dart';
import 'package:museumgo/screens/auth/login_page.dart';
import 'package:museumgo/screens/auth/registrasi_page.dart';
import 'package:museumgo/screens/admin/admin_home_page.dart';
import 'package:museumgo/screens/user/user_home_page.dart';
import 'package:museumgo/screens/user/riwayat_page.dart';
import 'package:museumgo/screens/user/profil_page.dart';
import 'package:museumgo/screens/admin/pengguna_page.dart';
import 'package:museumgo/screens/admin/laporan_page.dart';
import 'package:museumgo/screens/admin/admin_profil_page.dart';

class AppPages {
  static const initialRoute = '/splash';

  static final routes = [
    GetPage(name: '/splash', page: () => SplashscreenPage()),
    GetPage(name: '/login', page: () => LoginPage()),
    GetPage(name: '/register', page: () => RegistrasiPage()),
    GetPage(name: '/user-home', page: () => UserHomePage()),
    GetPage(name: '/riwayat', page: () => RiwayatPage()),
    GetPage(name: '/profil', page: () => ProfilPage()),
    GetPage(name: '/admin-home', page: () => AdminHomePage()),
    GetPage(name: '/pengguna', page: () => PenggunaPage()),

    GetPage(name: '/laporan', page: () => LaporanPage()),
    GetPage(name: '/admin-profil', page: () => AdminProfilPage()),
  ];
}
