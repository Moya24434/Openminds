import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/formation_model.dart';
import '../models/session_model.dart';

class AdminService {
  static const String baseUrl = "http://10.0.2.2/openminds_api";

  // --- US17 : RÉCUPÉRER LES STATISTIQUES GLOBALES ---
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

  // --- US15 : RÉCUPÉRER TOUTES LES FORMATIONS (pour les dropdowns) ---
  Future<List<Formation>> getFormations() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/get_formations.php"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          // Si on utilise "data" : []
          if (data.containsKey('data')) {
            return (data['data'] as List).map((item) => Formation.fromJson(item)).toList();
          } 
          // Si on utilise "formations" : []
          else if (data.containsKey('formations')) {
            return (data['formations'] as List).map((f) => Formation.fromJson(f)).toList();
          }
        } else if (data is List) {
          // Si c'est directement un Array PHP sans statut
          return data.map((item) => Formation.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Formation>> getAllFormations(int idUser) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/get_formations_admin.php"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"id_user": idUser}),
      );
      final data = json.decode(response.body);
      
      if (data is Map<String, dynamic> && data['status'] == 'success') {
        return (data['formations'] as List).map((f) => Formation.fromJson(f)).toList();
      } else if (data is List) {
        return data.map((f) => Formation.fromJson(f)).toList();
      }
      return [];
    } catch (e) {
      print("Erreur getAllFormations Admin : $e");
      return [];
    }
  }

  // --- US15 : CRÉER UNE FORMATION ---
  Future<bool> createFormation(int idUser, String titre, String description, String thematique, String? imageUrl) async {
    try {
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
    } catch (e) {
      print("Erreur lors de la création de la formation : $e");
      return false; // Permet à l'application de ne pas charger indéfiniment
    }
  }

  Future<bool> updateFormation(int idUser, int idFormation, String titre, String description, String thematique, String? imageUrl) async {
    try {
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
    } catch (e) {
      print("Erreur updateFormation : $e");
      return false;
    }
  }

  Future<bool> deleteFormation(int idUser, int idFormation) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/delete_formation.php"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"id_user": idUser, "id_formation": idFormation}),
      );
      final data = json.decode(response.body);
      return data['status'] == 'success';
    } catch (e) {
      print("Erreur deleteFormation : $e");
      return false;
    }
  }

  // ───────────── SESSIONS ─────────────

  Future<List<Session>> getAllSessions(int idUser) async {
    final response = await http.post(
      Uri.parse("$baseUrl/get_sessions_admin.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"id_user": idUser}),
    );
    final data = json.decode(response.body);
    if (data['status'] == 'success') {
      return (data['sessions'] as List).map((s) => Session.fromJson(s)).toList();
    }
    return [];
  }

  Future<bool> createSession(
      int idUser,
      int idFormation,
      String typeSession,
      String lieu,
      String dateDebut,
      String dateFin,
      double latitude, // Nouveau
      double longitude // Nouveau
      ) async {
    try {
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
          "latitude": latitude,   // Envoyé au PHP
          "longitude": longitude, // Envoyé au PHP
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      print("Erreur createSession: $e");
      return false;
    }
  }

  Future<bool> updateSession(
      int idUser,
      int idSession,
      int idFormation,
      String typeSession,
      String lieu,
      String dateDebut,
      String dateFin,
      double latitude, // Ajouté
      double longitude // Ajouté
      ) async {
    try {
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
          "latitude": latitude,   // Nouveau
          "longitude": longitude, // Nouveau
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      print("Erreur updateSession: $e");
      return false;
    }
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

}