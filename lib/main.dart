import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/api_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger les variables d'environnement si le fichier existe
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Le fichier .env n'existe pas, utiliser des valeurs par défaut
    debugPrint('Fichier .env non trouvé, utilisation des valeurs par défaut');
  }

  // Initialiser les clés API
  ApiKeys.initKeys({
    'FOOTBALL_API_KEY': dotenv.env['FOOTBALL_API_KEY'] ?? '',
    'GNEWS_API_KEY': dotenv.env['GNEWS_API_KEY'] ?? '',
    'GROQ_API_KEY': dotenv.env['GROQ_API_KEY'] ?? '',
  });

  // Configuration de l'orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configuration de la barre de statut
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Initialisation de Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: CANApp()));
}

class CANApp extends ConsumerWidget {
  const CANApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'CAN 2025 Morocco',
      debugShowCheckedModeBanner: false,

      // Configuration du thème
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // Configuration du routeur
      routerConfig: router,

      // Delegates de localisation
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Configuration de la localisation
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
        Locale('ar', 'MA'),
      ],

      // Builder pour les configurations globales
      builder: (context, child) {
        return MediaQuery(
          // Empêcher le redimensionnement du texte système
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
