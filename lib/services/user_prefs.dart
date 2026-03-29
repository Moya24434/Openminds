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
  }

  // Récupérer l'ID de l'utilisateur connecté
  static Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id_user');
  }

  // Déconnexion
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}