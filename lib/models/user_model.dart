class UserModel {
  final String userId;
  final String name;
  final String email;
  final String role;
  final String fotoUrl; // tambahkan field fotoUrl

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.fotoUrl, // tambahkan di constructor
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['user_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      fotoUrl: map['foto_url'] ?? '', // tambahkan ini
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'role': role,
      'foto_url': fotoUrl, // tambahkan ini
    };
  }
}
