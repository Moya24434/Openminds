import 'formation_model.dart'; // On importe le modèle Formation

class Session {
  final int idSession;
  final int idFormation;
  final String typeSession;
  final String adresse;
  final DateTime dateSession;
  final Formation? formation; // Optionnel : rempli si on fait un JOIN en SQL

  Session({
    required this.idSession,
    required this.idFormation,
    required this.typeSession,
    required this.adresse,
    required this.dateSession,
    this.formation,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      idSession: int.parse(json['id_session'].toString()),
      idFormation: int.parse(json['id_formation'].toString()),
      typeSession: json['type_session'] ?? "Présentiel",
      adresse: json['lieu'] ?? json['adresse'] ?? "Lieu non défini",
      // On gère les différents noms possibles selon comment tu as fait ton PHP
      dateSession: DateTime.parse(json['date_session'] ?? json['dateDebut']),

      // La magie est ici : si le JSON contient "titre" (donc le PHP a fait la jointure),
      // on crée l'objet Formation et on l'attache à la session.
      formation: json['titre'] != null ? Formation.fromJson(json) : null,
    );
  }
}