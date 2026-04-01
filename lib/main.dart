// lib/main.dart
import 'package:flutter/material.dart';
import 'pages/home_page.dart';// Importe ton nouveau fichier
import 'pages/splash_screen.dart';// Importe ton nouveau fichier

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenMinds SAE',
      theme: ThemeData(
        // Configure ton thème principal ici
        primaryColor: const Color(0xFF004AAD),
      ),
      home: const SplashScreen(), // <-- ON DEMARRE SUR LE SPLASH SCREEN
    );
  }
}