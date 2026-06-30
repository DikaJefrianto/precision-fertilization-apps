class UserModel {
  final int id;
  final String name;
  final String email;
  final String whatsapp;
  final String role;
  final String? foto_profil;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.whatsapp,
    required this.role,
    this.foto_profil,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
  return UserModel(
    id: json['id'],
    name: json['nama'],
    email: json['email'],
    whatsapp: json['no_whatsapp'] ?? "-",
    role: json['role'],
    foto_profil: (json['foto_profil'] ?? json['foto'] ?? json['foto_profile'])?.toString().trim(),
  );
}
}