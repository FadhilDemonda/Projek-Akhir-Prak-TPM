import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/notification_service.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kai/screens/stasiun/stasiun_favorite_screen.dart';
import 'package:kai/screens/stasiun/stasiun_list_screen.dart';
import 'routes.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/noisense/noisense_screen.dart';
import 'screens/noisense/location_info_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/panduan_screen.dart';
import 'screens/sarana_prasarana/sarana_screen.dart';
import 'screens/noisense/barcode_scanner.dart';
import 'constants/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await NotificationService().initialize();

  // Buka box tanpa tipe karena kita tidak menggunakan @HiveType/@HiveField
  var box = await Hive.openBox('userBox'); // Buka hanya sekali

  // Pastikan box sudah dibuka sebelum aplikasi berjalan
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
    _,
  ) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Noisense',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        Routes.splash: (context) => const SplashScreen(),
        Routes.login: (context) => const LoginScreen(),
        Routes.dashboard: (context) => const DashboardScreen(),
        Routes.profile: (context) => const ProfileScreen(),
        Routes.barcodeScanner: (context) => const BarcodeScannerPage(),
        Routes.noisense: (context) => const NoisenseScreen(),
        Routes.locationInfo: (context) => const MapScreen(),
        Routes.feedback: (context) => const FeedbackScreen(),
        Routes.panduan: (context) => const PanduanScreen(),
        Routes.saranaPrasarana: (context) => const SaranaPrasaranaScreen(),
        Routes.stasiun: (context) => const StasiunListPage(),
        Routes.favorite: (context) => const FavoritePage(),
        // Routes.stasiundetail: (context) => const StasiunDetailPage(stasiun: null,),
        Routes.register:
            (context) => const RegisterScreen(), // Tambahkan rute register
      },
    );
  }
}
