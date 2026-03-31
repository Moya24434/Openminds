import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/formation_model.dart';
import '../models/session_model.dart';

class AdminService {
  static const String baseUrl = "http://10.0.2.2/openminds_api";

  // ───────────── UTILISATEURS ─────────────

  Future<List<UserModel>> getAllUsers(int idUser) async {
    final response = await http.post(
      Uri.parse("$baseUrl/get_all_users.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"id_user": idUser}),
    );
    final data = json.decode(response.body);
    if (data['status'] == 'success') {
      return (data['users'] as List).map((u) => UserModel.fromJson(u)).toList();
    }
    return [];
  }

  Future<bool> deleteUser(int idUser, int idCible) async {
    final response = await http.post(
      Uri.parse("$baseUrl/delete_user.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"id_user": idUser, "id_cible": idCible}),
    );
    final data = json.decode(response.body);
    return data['status'] == 'success';
  }

  // ───────────── FORMATIONS ─────────────

  Future<List<Formation>> getAllFormations(int idUser) async {
    final response = await http.post(
      Uri.parse("$baseUrl/get_all_formations_admin.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"id_user": idUser}),
    );
    final data = json.decode(response.body);
    if (data['status'] == 'success') {
      return (data['formations'] as List).map((f) => Formation.fromJson(f)).toList();
    }
    return [];
  }

  Future<bool> createFormation(int idUser, String titre, String description, String thematique, String? imageUrl) async {
    final response = await http.post(
      Uri.parse("$baseUrl/create_formation.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "id_user": idUser,
        "titre": titre,
        "description": description,
        "thematique": thematique,
        "image_url": imageUrl,
      }),
    );
    final data = json.decode(response.body);
    return data['status'] == 'success';
  }

  Future<bool> updateFormation(int idUser, int idFormation, String titre, String description, String thematique, String? imageUrl) async {
    final response = await http.post(
      Uri.parse("$baseUrl/update_formation.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "id_user": idUser,
        "id_formation": idFormation,
        "titre": titre,
        "description": description,
        "thematique": thematique,
        "image_url": imageUrl,
      }),
    );
    final data = json.decode(response.body);
    return data['status'] == 'success';
  }

  Future<bool> deleteFormation(int idUser, int idFormation) async {
    final response = await http.post(
      Uri.parse("$baseUrl/delete_formation.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"id_user": idUser, "id_formation": idFormation}),
    );
    final data = json.decode(response.body);
    return data['status'] == 'success';
  }

  // ───────────── SESSIONS ─────────────

  Future<List<Session>> getAllSessions(int idUser) async {
    final response = await http.post(
      Uri.parse("$baseUrl/get_all_sessions_admin.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"id_user": idUser}),
    );
    final data = json.decode(response.body);
    if (data['status'] == 'success') {
      return (data['sessions'] as List).map((s) => Session.fromJson(s)).toList();
    }
    return [];
  }

  Future<bool> createSession(int idUser, int idFormation, String typeSession, String lieu, String dateDebut, String dateFin) async {
    final response = await http.post(
      Uri.parse("$baseUrl/create_session.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "id_user": idUser,
        "id_formation": idFormation,
        "type_session": typeSession,
        "lieu": lieu,
        "dateDebut": dateDebut,
        "dateFin": dateFin,
      }),
    );
    final data = json.decode(response.body);
    return data['status'] == 'success';
  }

  Future<bool> updateSession(int idUser, int idSession, int idFormation, String typeSession, String lieu, String dateDebut, String dateFin) async {
    final response = await http.post(
      Uri.parse("$baseUrl/update_session.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "id_user": idUser,
        "id_session": idSession,
        "id_formation": idFormation,
        "type_session": typeSession,
        "lieu": lieu,
        "dateDebut": dateDebut,
        "dateFin": dateFin,
      }),
    );
    final data = json.decode(response.body);
    return data['status'] == 'success';
  }

  Future<bool> deleteSession(int idUser, int idSession) async {
    final response = await http.post(
      Uri.parse("$baseUrl/delete_session.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"id_user": idUser, "id_session": idSession}),
    );
    final data = json.decode(response.body);
    return data['status'] == 'success';
  }

  // ───────────── MÉTHODES SIMPLIFIÉES (utilisées par les pages admin) ─────────────

  /// Récupère toutes les formations (pour les dropdowns et le catalogue admin)
  Future<List<Formation>> getFormations() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/get_formations.php"),
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          return (jsonData['data'] as List)
              .map((item) => Formation.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Récupère les statistiques globales pour l'admin (US17)
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/get_admin_stats.php"),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {"status": "error", "message": "Erreur serveur"};
    } catch (e) {
      return {"status": "error", "message": "Erreur de connexion : $e"};
    }
  }
}