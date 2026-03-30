import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {
    'prenom': TextEditingController(), 'nom': TextEditingController(),
    'email': TextEditingController(), 'ville': TextEditingController(),
    'cp': TextEditingController(), 'tel': TextEditingController(),
    'pass': TextEditingController(),
  };

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    final result = await AuthService().register({
      "prenom": controllers['prenom']!.text, "nom": controllers['nom']!.text,
      "email": controllers['email']!.text, "ville": controllers['ville']!.text,
      "code_postal": controllers['cp']!.text, "telephone": controllers['tel']!.text,
      "password": controllers['pass']!.text,
    });

    if (result['status'] == "success") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Compte créé ! Connectez-vous.")));
      Navigator.pop(context); // Revient au login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.grey),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Créer un compte", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF004AAD))),
              const Text("Rejoignez la communauté OpenMinds", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),
              _buildField(controllers['prenom']!, "Prénom", Icons.person_outline),
              _buildField(controllers['nom']!, "Nom", Icons.person_outline),
              _buildField(controllers['email']!, "Email", Icons.email_outlined),
              Row(
                children: [
                  Expanded(child: _buildField(controllers['ville']!, "Ville", Icons.location_city)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildField(controllers['cp']!, "Code postal", Icons.map_outlined)),
                ],
              ),
              _buildField(controllers['tel']!, "Téléphone", Icons.phone_android),
              _buildField(controllers['pass']!, "Mot de passe", Icons.lock_outline, obscure: true),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004AAD),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: registerUser,
                child: const Text("S'INSCRIRE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Déjà un compte ? Se connecter", style: TextStyle(color: Color(0xFF004AAD))),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, IconData icon, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF004AAD)),
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF004AAD))),
        ),
      ),
    );
  }
}