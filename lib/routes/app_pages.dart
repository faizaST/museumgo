import 'package:get/get.dart';
import 'package:museumgo/screens/auth/login_page.dart';
import 'package:museumgo/screens/auth/registrasi_page.dart';
import 'package:museumgo/screens/admin/admin_home_page.dart';
import 'package:museumgo/screens/user/user_home_page.dart';

class AppPages {
  static const initialRoute = '/login';

  static final routes = [
    GetPage(name: '/login', page: () => LoginPage()),
    GetPage(name: '/register', page: () => RegistrasiPage()),
    GetPage(name: '/admin-home', page: () => AdminHomePage()),
    GetPage(name: '/user-home', page: () => UserHomePage()),
  ];
}
