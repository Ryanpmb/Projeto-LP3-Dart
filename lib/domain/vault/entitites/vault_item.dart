import 'package:guardians/domain/crypto/encrypted_data.dart';
import 'item_type.dart';

class VaultItem {
  final String id;
  final String vaultId;
  final String name;
  final ItemType type;
  final String? description;
  final EncryptedData payload;
  final DateTime createdAt;
  final DateTime updatedAt;

  VaultItem({
    required this.id,
    required this.vaultId,
    required this.name,
    required this.type,
    this.description,
    required this.payload,
    required this.createdAt,
    required this.updatedAt,
  });
}