class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? passwordHash;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.passwordHash,
    this.createdAt,
    this.updatedAt,
  });
}
