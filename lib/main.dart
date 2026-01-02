import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/afcon_welcome_page.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/forgot_password_page.dart';
import 'screens/afcon_home_page.dart';
import 'screens/fanzone_page.dart';
import 'screens/stadiums_page.dart';
import 'screens/buy_tickets_page.dart';
import 'screens/afcon_history_page.dart';
import 'screens/currency_converter_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AFCON CAN 2025',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE63946)),
        useMaterial3: true,
      ),
      home: const AFCONWelcomePage(),
      routes: {
        '/welcome': (context) => const AFCONWelcomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/forgot': (context) => const ForgotPasswordPage(),
        '/home': (context) => const AFCONHomePage(),
        '/fanzone': (context) => const FanzonePage(),
        '/stadiums': (context) => const StadiumsPage(),
        '/tickets': (context) => const BuyTicketsPage(),
        '/history': (context) => const AFCONHistoryPage(),
        '/currency': (context) => const CurrencyConverterPage(),
      },
    );
  }
}

// Old demo home page removed; app now opens the Moroccan welcome screen.
