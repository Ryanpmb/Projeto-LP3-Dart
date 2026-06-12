class CredentialPayload {
  final String username;
  final String password;
  final String? url;

  const CredentialPayload({
    required this.username,
    required this.password,
    this.url,
  });
}