import 'formation_model.dart';

class Session {
  final int idSession;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String adresse;
  final String typeSession;
  final Formation? formation;
  final double? distance;

  Session({
    required this.idSession,
    required this.dateDebut,
    required this.dateFin,
    required this.adresse,
    required this.typeSession,
    this.formation,
    this.distance,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      idSession: int.parse(json['id_session'].toString()),
      dateDebut: DateTime.parse(json['date_debut']),
      dateFin: DateTime.parse(json['date_fin']),
      adresse: json['lieu'] ?? 'Adresse non précisée',
      typeSession: json['type_session'],
      formation: Formation.fromJson(json),
      distance: json['distance'] != null ? double.parse(json['distance'].toString()) : null,
    );
  }
}