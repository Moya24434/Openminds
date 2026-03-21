import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'register_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void handleLogin() async {
    setState(() => isLoading = true);

    UserModel? user = await AuthService().login(
      emailController.text.trim(),
      passwordController.text,
    );

    setState(() => isLoading = false);

    if (user != null) {
      // 1. Message de bienvenue
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Bienvenue ${user.prenom} !"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 0), // Message court pour ne pas bloquer l'écran
        ),
      );

      // 2. Transition fluide vers la HomePage
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Animation de fondu (Fade)
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800), // 0.8 seconde pour la douceur
        ),
      );
    } else {
      // Cas d'échec
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email ou mot de passe incorrect"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 80),
            // Image.asset('assets/images/OpenMindsLogo.png', height: 120), // Vérifie que le chemin est bon
            const Text("OPEN MINDS", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF004AAD))),
            const SizedBox(height: 40),
            _buildInput(emailController, "Email"),
            const SizedBox(height: 15),
            _buildInput(passwordController, "Mot de passe", obscure: true),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: () {}, child: const Text("Mot de passe oublié ?")),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004AAD),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: handleLogin,
              child: const Text("SE CONNECTER", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 30),
            const Text("Nouveau sur OpenMinds ?"),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage())),
              child: const Text("Créer un compte", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }
}