import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

// ════════════════════════════════════════════════════════════
//  ThemeProvider — Light/Dark mode state manage karta hai
//  Ye ek simple ValueNotifier hai, koi extra package nahi
// ════════════════════════════════════════════════════════════
class ThemeProvider extends ChangeNotifier {
  bool _isDark = true; // App default dark mode mein khulti hai

  bool get isDark => _isDark;

  // Toggle karo — profile screen se call hoga
  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners(); // Poori app ko batao theme change hui
  }
}

// Global instance — kisi bhi screen se access kar sako
final themeProvider = ThemeProvider();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.instance.initialize();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    // ThemeProvider listen karo — theme change hone pe rebuild karo
    themeProvider.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ── DARK THEME ─────────────────────────────────────
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0818),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7C6FE8),
          secondary: Color(0xFFAB9FF8),
          surface: Color(0xFF1C1836),
          background: Color(0xFF0A0818),
        ),
        cardColor: const Color(0xFF1C1836),
        dividerColor: Colors.white12,
        textTheme: const TextTheme(
          bodyLarge:  TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF1C1836),
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
      ),

      // ── LIGHT THEME ────────────────────────────────────
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF0EFFF),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF7C6FE8),
          secondary: Color(0xFF5A4FD6),
          surface: Colors.white,
          background: Color(0xFFF0EFFF),
        ),
        cardColor: Colors.white,
        dividerColor: Colors.black12,
        textTheme: const TextTheme(
          bodyLarge:  TextStyle(color: Color(0xFF1A1730)),
          bodyMedium: TextStyle(color: Color(0xFF3D3A5C)),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF7C6FE8),
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
      ),

      // ── ACTIVE THEME ───────────────────────────────────
      themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,

      home: SplashScreen(),
    );
  }
}