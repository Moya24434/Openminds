class UserModel {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String role;
  final String? imageUrl;    // Optionnel car peut être NULL en BDD
  final String? ville;       // Optionnel
  final String? codePostal;  // Optionnel

  UserModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
    this.imageUrl,
    this.ville,
    this.codePostal,
  });

  // Transforme le JSON du PHP en objet Dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.parse(json['id_user'].toString()),
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'Bénévole',
      imageUrl: json['image_url'],     // Récupère l'URL du PHP
      ville: json['ville'],           // Récupère la ville du PHP
      codePostal: json['code_postal'], // Récupère le CP du PHP
    );
  }

  // Optionnel : utile si tu veux transformer l'objet en JSON plus tard
  Map<String, dynamic> toJson() {
    return {
      'id_user': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'role': role,
      'image_url': imageUrl,
      'ville': ville,
      'code_postal': codePostal,
    };
  }
}