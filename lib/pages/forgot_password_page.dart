import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendResetRequest() async {
    if (_emailController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // Remplace par ton IP locale (10.0.2.2 pour l'émulateur)
      final response = await http.post(
        Uri.parse("http://10.0.2.2/openminds_api/forgot_password.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": _emailController.text.trim()}),
      );

      final result = jsonDecode(response.body);

      if (mounted) {
        _showDialog(
          result['status'] == "success" ? "Lien envoyé ! 📧" : "Erreur",
          result['message'],
          isSuccess: result['status'] == "success",
        );
      }
    } catch (e) {
      debugPrint("Erreur: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDialog(String title, String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: TextStyle(color: isSuccess ? Colors.green : Colors.red)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (isSuccess) Navigator.pop(context); // Retour au login
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(elevation: 0, backgroundColor: Colors.white, foregroundColor: const Color(0xFF004AAD)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.lock_reset, size: 100, color: Color(0xFF004AAD)),
            const SizedBox(height: 30),
            const Text(
              "Mot de passe oublié ?",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF004AAD)),
            ),
            const SizedBox(height: 15),
            const Text(
              "Entrez votre adresse email. Si elle existe, nous vous enverrons un lien pour réinitialiser votre mot de passe.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Votre adresse email",
                prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF004AAD)),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator(color: Color(0xFF004AAD))
                : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004AAD),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: _sendResetRequest,
              child: const Text("ENVOYER LE LIEN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}