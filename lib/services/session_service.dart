import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/session_model.dart';

class SessionService {
  static const String url = "http://10.0.2.2/openminds_api/get_sessions.php";

  Future<List<Session>> getSessions() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List).map((s) => Session.fromJson(s)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}