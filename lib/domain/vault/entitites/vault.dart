class Vault {
  final String id;
  final String userId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vault({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
}