import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  bool _isLoading = false;

  Future<void> _changePassword() async {
    if (_oldPassController.text.isEmpty || _newPassController.text.isEmpty) return;
    setState(() => _isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('id_user') ?? 0;

    final response = await http.post(
      Uri.parse("http://10.0.2.2/openminds_api/change_password.php"),
      body: jsonEncode({
        "id_user": userId,
        "old_password": _oldPassController.text,
        "new_password": _newPassController.text,
      }),
    );

    final result = jsonDecode(response.body);
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message']), backgroundColor: result['status'] == "success" ? Colors.green : Colors.red),
    );
    if (result['status'] == "success") Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sécurité"), foregroundColor: Color(0xFF004AAD), backgroundColor: Colors.white, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _oldPassController, obscureText: true, decoration: const InputDecoration(labelText: "Ancien mot de passe")),
            const SizedBox(height: 20),
            TextField(controller: _newPassController, obscureText: true, decoration: const InputDecoration(labelText: "Nouveau mot de passe")),
            const SizedBox(height: 40),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004AAD), minimumSize: const Size(double.infinity, 50)),
                onPressed: _changePassword,
                child: const Text("MODIFIER LE MOT DE PASSE", style: TextStyle(color: Colors.white))
            ),
          ],
        ),
      ),
    );
  }
}