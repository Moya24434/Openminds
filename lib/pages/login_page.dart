import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../services/user_prefs.dart';
import 'main_screen.dart';
import 'register_page.dart';
import 'home_page.dart';
import 'privacy_policy_page.dart'; // N'oublie pas d'avoir créé ce fichier !

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _verifierConsentement();
  }

  // Fonction qui va lire la mémoire du téléphone
  Future<void> _verifierConsentement() async {
    final prefs = await SharedPreferences.getInstance();
    bool aDejaAccepte = prefs.getBool('rgpd_accepte') ?? false;

    if (!aDejaAccepte) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        afficherPopupRGPD(context);
      });
    }
  }

  void handleLogin() async {
    setState(() => isLoading = true);

    UserModel? user = await AuthService().login(
      emailController.text.trim(),
      passwordController.text,
    );

    setState(() => isLoading = false);

    if (user != null) {
      await UserPrefs.saveUser(user);

      // Sécurité Flutter : on vérifie que la page est toujours là avant d'afficher un message
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bienvenue ${user.prenom} !"), backgroundColor: Colors.green),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      if (!mounted) return;
      // Optionnel : un petit message rouge si le mot de passe est faux
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur de connexion"), backgroundColor: Colors.red),
      );
    }
  }

  // Fonction pour afficher le pop-up RGPD
  void afficherPopupRGPD(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Empêche de fermer en cliquant à côté
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Vos données, vos droits 🔒"),
          content: const Text(
            "Bienvenue sur OpenMinds !\n\n"
                "Pour fonctionner, notre application a besoin de collecter quelques données (email, nom, ville). "
                "Ces données sont stockées de manière sécurisée et ne seront jamais revendues.\n\n"
                "Conformément au RGPD, vous disposez d'un droit d'accès, de modification et de suppression de votre compte à tout moment.",
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('rgpd_accepte', true);

                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
              child: const Text("J'accepte"),
            ),
          ],
        );
      },
    );
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
            // Image.asset('assets/images/OpenMindsLogo.png', height: 120),
            const Text(
                "OPEN MINDS",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF004AAD))
            ),
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

      // La zone collée tout en bas de l'écran
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                  );
                },
                child: const Text(
                  "Politique de confidentialité",
                  style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
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