import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'dart:io' show Platform;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart'; // Import Intl
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Import localizations

import 'providers/navigation_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_screen.dart';
import 'screens/pin_auth_screen.dart';
import 'screens/register_debt_screen.dart';
import 'screens/register_investment_screen.dart';
import 'screens/quiz_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set the default locale for the entire app
  await initializeDateFormatting('es_PE', null);
  Intl.defaultLocale = 'es_PE';

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Future<bool> _checkPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('user_pin');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkPin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          return const PinAuthScreen();
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          const Color primaryColor = Color(0xFF122E2A);
          const Color accentColor = Color(0xFF30E182);
          const Color darkBackgroundColor = Color(0xFF0A1A18);

          final TextTheme appTextTheme = TextTheme(
            displayLarge: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
            titleLarge: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            bodyMedium: GoogleFonts.poppins(fontSize: 16, color: Colors.white.withAlpha(204)),
            labelLarge: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          );

          final ThemeData darkTheme = ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            primaryColor: primaryColor,
            scaffoldBackgroundColor: darkBackgroundColor,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryColor,
              brightness: Brightness.dark,
              primary: primaryColor,
              secondary: accentColor,
            ),
            textTheme: appTextTheme,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: appTextTheme.titleLarge,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                foregroundColor: primaryColor,
                backgroundColor: accentColor,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: appTextTheme.labelLarge,
              ),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: primaryColor,
              selectedItemColor: accentColor,
              unselectedItemColor: Colors.white.withAlpha(153),
              type: BottomNavigationBarType.fixed,
            ),
          );

          final ThemeData lightTheme = ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            primaryColor: accentColor,
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(
              seedColor: accentColor,
              brightness: Brightness.light,
              primary: accentColor,
              secondary: primaryColor,
            ),
            textTheme: appTextTheme.apply(
              bodyColor: primaryColor,
              displayColor: primaryColor,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: appTextTheme.titleLarge?.copyWith(color: primaryColor),
              iconTheme: IconThemeData(color: primaryColor),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: appTextTheme.labelLarge?.copyWith(color: Colors.white),
              ),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: primaryColor,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
            ),
          );

          return MaterialApp(
            title: 'Zero Deudas',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,
            // Add localization delegates
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('es', 'PE'), // Peru
              Locale('en', 'US'), // English as fallback
            ],
            locale: const Locale('es', 'PE'), // Set the locale
            home: const AuthWrapper(),
            routes: {
              '/main': (context) => const MainScreen(),
              '/register_debt': (context) => const RegisterDebtScreen(),
              '/register_investment': (context) => const RegisterInvestmentScreen(),
              '/quiz': (context) => const QuizScreen(),
            },
          );
        },
      ),
    );
  }
}
