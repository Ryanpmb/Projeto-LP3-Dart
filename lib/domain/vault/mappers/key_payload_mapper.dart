import '../entities/key_payload.dart';

class KeyPayloadMapper {
  static KeyPayload fromMap(Map<String, dynamic> map) {
    return KeyPayload(
      content: map['content'] as String,
    );
  }

  static Map<String, dynamic> toMap(KeyPayload keyPayload) {
    return {
      'content': keyPayload.content,
    };
  }
}