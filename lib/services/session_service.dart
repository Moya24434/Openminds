import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/session_model.dart';

class SessionService {
  // 1. On définit UNE SEULE FOIS l'adresse de base du dossier API (sans nom de fichier à la fin)
  static const String baseUrl = "http://10.0.2.2/openminds_api";

  // --- RÉCUPÉRER TOUTES LES SESSIONS ---
  Future<List<Session>> getSessions() async {
    try {
      // 2. On utilise $baseUrl et on rajoute le nom du fichier
      final response = await http.get(Uri.parse("$baseUrl/get_sessions.php"));

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
}