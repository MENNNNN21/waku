import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';

// Pastikan sudah buat file firebase_options.dart jika menggunakan FlutterFire CLI
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform, // uncomment jika pakai FlutterFire CLI
  );
  runApp(const WakuApp());
}

class WakuApp extends StatelessWidget {
  const WakuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waku - Manajemen Stok',
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) =>  SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        // nanti tambahkan route lain seperti stok, tambah barang, laporan dll
      },
    );
  }
}
