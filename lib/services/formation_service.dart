import 'dart:convert';
import 'dart:io';
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
  // --- NOUVELLE MÉTHODE : CRÉER UNE FORMATION (Admin) ---
  Future<Map<String, dynamic>> createFormation(Map<String, String> data, {File? imageFile}) async {
    try {
      var uri = Uri.parse("$baseUrl/create_formation.php");
      var request = http.MultipartRequest('POST', uri);

      request.fields.addAll(data);

      if (imageFile != null) {
        var multipartFile = await http.MultipartFile.fromPath(
          'image', // Doit correspondre au $_FILES['image'] en PHP
          imageFile.path,
        );
        request.files.add(multipartFile);
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      return json.decode(responseData);

    } catch (e) {
      print("Erreur création formation : $e");
      return {"status": "error", "message": "Erreur de connexion"};
    }
  }
}