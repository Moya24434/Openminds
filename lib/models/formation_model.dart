class Formation {
  final int id;
  final String titre;
  final String adresse;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String description;
  final String thematique;
  final String? image;

  Formation({
    required this.id,
    required this.titre,
    required this.adresse,
    required this.dateDebut,
    required this.dateFin,
    required this.description,
    required this.thematique,
    this.image,
  });

  factory Formation.fromJson(Map<String, dynamic> json) {
    return Formation(
      id: int.parse(json['id_formation'].toString()),
      titre: json['titre'] ?? "Formation",
      description: json['description'] ?? "",
      thematique: json['thematique'] ?? "",
      adresse: json['adresse'] ?? "",
      dateDebut: DateTime.parse(json['dateDebut']),
      dateFin: DateTime.parse(json['dateFin']),// ← parser en DateTime
      // image non lue depuis le JSON car non présente en BD
    );
  }
}