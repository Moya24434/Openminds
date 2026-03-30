import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/session_model.dart';

class SessionService {
  // 1. On définit UNE SEULE FOIS l'adresse de base du dossier API (sans nom de fichier à la fin)
  static const String baseUrl = "http://10.0.2.2/openminds_api";


  // --- RÉCUPÉRER TOUTES LES SESSIONS (AVEC OU SANS GPS) ---
  // On ajoute les { } pour rendre les paramètres optionnels
  Future<List<Session>> getSessions({double? lat, double? lng}) async {
    try {
      // Ton adresse de base (utilise get_sessions.php si tu as mis le code PHP dedans)
      String requestUrl = "$baseUrl/get_sessions.php";

      // Si le téléphone a envoyé ses coordonnées, on les colle à l'URL !
      if (lat != null && lng != null) {
        requestUrl += "?lat=$lat&lng=$lng";
      }

      final response = await http.get(Uri.parse(requestUrl));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((s) => Session.fromJson(s)).toList();
      }
      return [];
    } catch (e) {
      print("Erreur SessionService : $e");
      return [];
    }
  }


  // --- S'INSCRIRE À UNE SESSION ---
  Future<Map<String, dynamic>> inscrireSession(int idUser, int idSession) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/inscrire_session.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id_user": idUser,
          "id_session": idSession,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      print("Erreur réseau (Inscription Session) : $e");
      return {"status": "error", "message": "Impossible de joindre le serveur"};
    }
  }

  // --- SE DÉSINSCRIRE D'UNE SESSION ---
  Future<Map<String, dynamic>> desinscrireSession(int idUser, int idSession) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/desinscrire_session.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id_user": idUser,
          "id_session": idSession
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      print("Erreur réseau (Désinscription Session) : $e");
      return {"status": "error", "message": "Impossible de joindre le serveur"};
    }
  }

  // --- RÉCUPÉRER LES SESSIONS D'UN UTILISATEUR ("À VENIR") ---
  Future<List<Session>> getUserSessions(int idUser) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/get_user_sessions.php?id_user=$idUser"));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((s) => Session.fromJson(s)).toList();
      }
      return [];
    } catch (e) {
      print("Erreur réseau (getUserSessions) : $e");
      return [];
    }
  }

  Future<List<dynamic>> getUserHistory(int userId) async {
    final response = await http.get(
      Uri.parse("http://10.0.2.2/openminds_api/get_user_history.php?id_user=$userId"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur lors de la récupération de l'historique");
    }
  }
}