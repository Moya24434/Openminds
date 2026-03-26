class Session {
  final int idSession;
  final int idFormation;
  final String typeSession;  // "Présentiel" ou "En ligne"
  final String adresse;
  final DateTime dateDebut;
  final DateTime dateFin;

  Session({
    required this.idSession,
    required this.idFormation,
    required this.typeSession,
    required this.adresse,
    required this.dateDebut,
    required this.dateFin
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      idSession: int.parse(json['id_session'].toString()),
      idFormation: int.parse(json['id_formation'].toString()),
      typeSession: json['type_session'] ?? "Session",
      adresse: json['lieu'] ?? "Lieu non défini",
      dateDebut: DateTime.parse(json['dateDebut']),
      dateFin: DateTime.parse(json['dateFin']),
    );
  }
}