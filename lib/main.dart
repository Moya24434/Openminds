import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OpenMinds SAE',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF004AAD),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF004AAD)),
      ),
      home: const SplashScreen(),
    );
  }
}
