import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../services/user_prefs.dart';
import 'main_screen.dart';
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

  // Dans login_page.dart, modifie handleLogin :

  void handleLogin() async {
    setState(() => isLoading = true);

    UserModel? user = await AuthService().login(
      emailController.text.trim(),
      passwordController.text,
    );

    setState(() => isLoading = false);

    if (user != null) {
      // --- ON SAUVEGARDE ICI ---
      await UserPrefs.saveUser(user);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bienvenue ${user.prenom} !"), backgroundColor: Colors.green),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      // Erreur...
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