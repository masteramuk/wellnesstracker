import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthtracker/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      title: 'HealthTracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          primary: Colors.teal[300]!,
          secondary: Colors.grey[500]!,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.latoTextTheme(textTheme).copyWith(
          headlineSmall: GoogleFonts.montserrat(textStyle: textTheme.headlineSmall, fontWeight: FontWeight.bold, color: Colors.white),
          titleLarge: GoogleFonts.montserrat(textStyle: textTheme.titleLarge, fontWeight: FontWeight.bold, color: Colors.white),
          titleMedium: GoogleFonts.montserrat(textStyle: textTheme.titleMedium, fontWeight: FontWeight.w600, color: Colors.white70),
          bodyMedium: GoogleFonts.lato(textStyle: textTheme.bodyMedium, fontSize: 16, color: Colors.white70),
          labelLarge: GoogleFonts.lato(textStyle: textTheme.labelLarge, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white.withAlpha(26),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.white30, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.teal[300]!, width: 2),
          ),
          labelStyle: const TextStyle(color: Colors.white70),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal[400],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black.withAlpha(128),
          selectedItemColor: Colors.teal[300],
          unselectedItemColor: Colors.grey[400],
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
