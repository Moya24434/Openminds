import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/formation_model.dart';

class FormationService {
  static const String baseUrl = 'http://10.0.2.2/openminds_api'; // émulateur
  // static const String baseUrl = 'http://192.168.1.XX/projet_api'; // vrai appareil

  Future<List<Formation>> getFormations() async {
    final response = await http.get(Uri.parse('$baseUrl/get_formations.php'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      if (json['status'] == 'success') {
        return (json['data'] as List).map((item) => Formation.fromJson(item)).toList();
      } else {
        throw Exception(json['message']);
      }
    } else {
      throw Exception('Erreur serveur : ${response.statusCode}');
    }
  }
}