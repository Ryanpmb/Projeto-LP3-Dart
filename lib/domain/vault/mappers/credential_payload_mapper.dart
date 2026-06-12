import '../entities/credential_payload.dart';

class CredentialPayloadMapper {
  static CredentialPayload fromMap(Map<String, dynamic> map) {
    return CredentialPayload(
      username: map['username'] as String,
      password: map['password'] as String,
      url: map['url'] as String?,
    );
  }

  static Map<String, dynamic> toMap(CredentialPayload credentialPayload) {
    return {
      'username': credentialPayload.username,
      'password': credentialPayload.password,
      'url': credentialPayload.url,
    };
  }
}