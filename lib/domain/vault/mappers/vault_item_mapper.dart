import 'package:guardians/domain/crypto/encrypted_data.dart';
import '../entities/vault_item.dart';
import '../entities/item_type.dart';

class VaultItemMapper {
  static VaultItem fromMap(Map<String, dynamic> map) {
    final typeValue = map['type'] as String;

    return VaultItem(
      id: map['id'] as String,
      vaultId: map['vault_id'] as String,
      name: map['name'] as String,
      type: ItemType.values.firstWhere((itemType) => itemType.name == typeValue),
      description: map['description'] as String?,
      payload: EncryptedData.fromMap(map['payload'] as Map<String, dynamic>),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  static Map<String, dynamic> toMap(VaultItem item) {
    return {
      'id': item.id,
      'vault_id': item.vaultId,
      'name': item.name,
      'type': item.type.name,
      'description': item.description,
      'payload': item.payload.toMap(),
      'created_at': item.createdAt.toIso8601String(),
      'updated_at': item.updatedAt.toIso8601String(),
    };
  }
}