import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import  '../services/auth_service.dart';
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  // Contrôleurs pour récupérer les textes
  final Map<String, TextEditingController> controllers = {
    'prenom': TextEditingController(),
    'nom': TextEditingController(),
    'email': TextEditingController(),
    'ville': TextEditingController(),
    'cp': TextEditingController(),
    'tel': TextEditingController(),
    'pass': TextEditingController(),
  };

  // Remplace ton ancienne fonction registerUser par celle-ci
  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = AuthService();
    final result = await authService.register({
      "prenom": controllers['prenom']!.text,
      "nom": controllers['nom']!.text,
      "email": controllers['email']!.text,
      "ville": controllers['ville']!.text,
      "code_postal": controllers['cp']!.text,
      "telephone": controllers['tel']!.text,
      "password": controllers['pass']!.text,
    });

    if (result['status'] == "success") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Compte créé !")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 50),
              Text("CRÉER MON COMPTE", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF004AAD))),
              SizedBox(height: 30),
              _buildField(controllers['prenom']!, "Prénom"),
              _buildField(controllers['nom']!, "Nom"),
              _buildField(controllers['email']!, "Email"),
              Row(
                children: [
                  Expanded(child: _buildField(controllers['ville']!, "Ville")),
                  SizedBox(width: 10),
                  Expanded(child: _buildField(controllers['cp']!, "Code postal")),
                ],
              ),
              _buildField(controllers['tel']!, "Numéro de téléphone"),
              _buildField(controllers['pass']!, "Mot de passe", obscure: true),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF004AAD),
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: registerUser,
                child: Text("JE CRÉE MON COMPTE", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}