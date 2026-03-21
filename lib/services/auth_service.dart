import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  // Adresse IP de ton PC (10.0.2.2 pour l'émulateur Android)
  static const String baseUrl = "http://10.0.2.2/openminds_api";

  // Fonction Inscription
  Future<Map<String, dynamic>> register(Map<String, String> data) async {
    final response = await http.post(Uri.parse("$baseUrl/register.php"), body: data);
    return json.decode(response.body);
  }

  // Fonction Connexion
  Future<UserModel?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login.php"),
      body: {"email": email, "password": password},
    );

    final data = json.decode(response.body);
    if (data['status'] == "success") {
      return UserModel.fromJson(data['user']);
    }
    return null; // Retourne null si la connexion échoue
  }
}