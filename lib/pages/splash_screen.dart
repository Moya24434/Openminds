// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:openminds/pages/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    // Temps d'attente du splash (3 secondes)
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Transition fluide vers la HomePage
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(), // VERIFIE LE NOM ICI
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF004AAD),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ton logo
            Icon(Icons.auto_awesome, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              "OpenMinds",
              style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}