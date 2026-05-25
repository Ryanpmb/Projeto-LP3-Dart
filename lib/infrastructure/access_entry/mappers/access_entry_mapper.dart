import '../../../domain/access_entry/entities/access_entry.dart';

class AccessEntryMapper {
  static AccessEntry fromMap(Map<String, dynamic> map) {
    return AccessEntry(
      id: map['id'] as String,
      name: map['name'] as String,
      access: map['access'] as String,
      password: map['password'] as String,
    );
  }

  static Map<String, dynamic> toMap(AccessEntry accessEntry) {
    return {
      'id': accessEntry.id,
      'name': accessEntry.name,
      'access': accessEntry.access,
      'password': accessEntry.password,
    };
  }
}