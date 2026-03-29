import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  // Adresse IP pour l'émulateur Android (remplace par ton IP si tu utilises un vrai téléphone)
  static const String baseUrl = "http://10.0.2.2/openminds_api";

  // --- MÉTHODE 1 : INSCRIPTION (REGISTER) ---
  Future<Map<String, dynamic>> register(Map<String, String> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register.php"),
        body: data, // L'envoi classique fonctionne très bien avec le script PHP que je t'ai donné
      );

      // On retourne la réponse du serveur (succès ou erreur)
      return json.decode(response.body);
    } catch (e) {
      print("Erreur réseau (Inscription) : $e");
      return {"status": "error", "message": "Impossible de joindre le serveur"};
    }
  }

  // --- MÉTHODE 2 : CONNEXION (LOGIN) ---
  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login.php"),
        headers: {"Content-Type": "application/json"}, // On précise le format
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          // Succès : on renvoie l'objet utilisateur
          return UserModel.fromJson(data['user']);
        } else {
          // Échec (mauvais mot de passe, etc.)
          print("Erreur API (Connexion) : ${data['message']}");
          return null;
        }
      }
    } catch (e) {
      print("Erreur réseau (Connexion) : $e");
    }
    return null; // Retourne null si quelque chose s'est mal passé
  }
}