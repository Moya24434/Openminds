class Formation {
  final int idFormation;
  final String titre;
  final String description;
  final String? thematique;
  final String? imageUrl; // 1. On déclare la variable ici (avec un ? car elle peut être nulle)

  Formation({
    required this.idFormation,
    required this.titre,
    required this.description,
    this.thematique,
    this.imageUrl, // 2. On l'ajoute au constructeur
  });

  factory Formation.fromJson(Map<String, dynamic> json) {
    return Formation(
      idFormation: int.parse(json['id_formation'].toString()),
      titre: json['titre'] ?? "Formation sans titre",
      description: json['description'] ?? "Pas de description",
      thematique: json['thematique'],
      imageUrl: json['image_url'], // 3. On fait le lien avec le nom exact renvoyé par le PHP
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Formation &&
          runtimeType == other.runtimeType &&
          idFormation == other.idFormation;

  @override
  int get hashCode => idFormation.hashCode;
}