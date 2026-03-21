class UserModel {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String role;

  UserModel({required this.id, required this.nom, required this.prenom, required this.email, required this.role});

  // Transforme le JSON du PHP en objet Dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.parse(json['id_user'].toString()),
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      role: json['role'],
    );
  }
}