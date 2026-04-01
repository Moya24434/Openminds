import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../services/user_prefs.dart';
import 'forgot_password_page.dart';
import 'main_screen.dart';
import 'register_page.dart';
import 'privacy_policy_page.dart';

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
    if (emailController.text.isEmpty || passwordController.text.isEmpty) return;
    setState(() => isLoading = true);
    UserModel? user = await AuthService().login(emailController.text.trim(), passwordController.text);
    setState(() => isLoading = false);

    if (user != null) {
      await UserPrefs.saveUser(user);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email ou mot de passe incorrect"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, size: 80, color: Color(0xFF004AAD)),
              const SizedBox(height: 10),
              const Text("OPEN MINDS", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF004AAD))),
              const Text("Espace Bénévole", style: TextStyle(color: Colors.grey, letterSpacing: 1.2)),
              const SizedBox(height: 50),
              _buildInput(emailController, "Email", Icons.email_outlined),
              const SizedBox(height: 15),
              _buildInput(passwordController, "Mot de passe", Icons.lock_outline, obscure: true),
              // ... après le champ Mot de passe
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                    );
                  },
                  child: const Text(
                    "Mot de passe oublié ?",
                    style: TextStyle(color: Color(0xFF004AAD), fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 20),
// ... avant le bouton SE CONNECTER
              const SizedBox(height: 30),
              isLoading
                  ? const CircularProgressIndicator(color: Color(0xFF004AAD))
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004AAD),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                onPressed: handleLogin,
                child: const Text("SE CONNECTER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Pas encore membre ?"),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage())),
                    child: const Text("Créer un compte", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF004AAD))),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyPage())),
                child: const Text("Politique de confidentialité", style: TextStyle(color: Colors.grey, fontSize: 12, decoration: TextDecoration.underline)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF004AAD)),
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[50],
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF004AAD))),
      ),
    );
  }
}