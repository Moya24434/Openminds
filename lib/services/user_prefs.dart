import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserPrefs {
  // Sauvegarder l'utilisateur après le login
  static Future<void> saveUser(UserModel user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id_user', user.id); // Utilise le nom exact de ton modèle
    await prefs.setString('prenom', user.prenom);
    await prefs.setString('role', user.role);
    await prefs.setBool('isLoggedIn', true);

    // --- AJOUTS POUR LA SAUVEGARDE COMPLÈTE ---
    await prefs.setString('nom', user.nom);
    await prefs.setString('email', user.email);
    await prefs.setString('image_url', user.imageUrl ?? '');
    await prefs.setString('ville', user.ville ?? '');
    await prefs.setString('code_postal', user.codePostal ?? '');
  }

  // Récupérer l'ID de l'utilisateur connecté
  static Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id_user');
  }

  // --- NOUVELLES FONCTIONS DE RÉCUPÉRATION ---

  static Future<String> getPrenom() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('prenom') ?? '';
  }

  static Future<String> getImageUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('image_url') ?? '';
  }

  static Future<String> getVille() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('ville') ?? '';
  }

  static Future<String> getCP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('code_postal') ?? '';
  }

  // Déconnexion
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}