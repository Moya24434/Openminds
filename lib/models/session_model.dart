class Session {
  final int id;
  final String titre;
  final String adresse;
  final String date;
  final String description;

  Session({required this.id, required this.titre, required this.adresse, required this.date, required this.description});

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: int.parse(json['id_session'].toString()),
      titre: json['titre'] ?? "Formation",
      adresse: json['lieu'] ?? "Lieu non défini",
      date: json['date_session'] ?? "",
      description: json['description'] ?? "",
    );
  }
}