import 'formation_model.dart'; // On importe le modèle Formation

class Session {
  final int idSession;
  final DateTime dateSession;
  final String adresse;
  final String typeSession;
  final Formation? formation;
  final double? distance; // <-- NOUVEAU : Peut être nul si le GPS est désactivé

  Session({
    required this.idSession,
    required this.dateSession,
    required this.adresse,
    required this.typeSession,
    this.formation,
    this.distance, // <-- NOUVEAU
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      idSession: int.parse(json['id_session'].toString()),
      dateSession: DateTime.parse(json['date_session']),
      // On dit à Flutter de lire 'lieu' dans la base de données !
      adresse: json['lieu'] ?? 'Adresse non précisée',
      typeSession: json['type_session'],
      formation: Formation.fromJson(json),
      distance: json['distance'] != null ? double.parse(json['distance'].toString()) : null,
    );
  }
}