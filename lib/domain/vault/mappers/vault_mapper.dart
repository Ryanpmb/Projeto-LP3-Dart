import '../entities/vault.dart';

class VaultMapper {
  static Vault fromMap(Map<String, dynamic> map) {
    return Vault(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  static Map<String, dynamic> toMap(Vault vault) {
    return {
      'id': vault.id,
      'user_id': vault.userId,
      'name': vault.name,
      'created_at': vault.createdAt.toIso8601String(),
      'updated_at': vault.updatedAt.toIso8601String(),
    };
  }
}