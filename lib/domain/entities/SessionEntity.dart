class SessionEntity {
  final String token;
  final String? refreshToken;
  final DateTime? expiresAt;
  final String? devices;

  SessionEntity({
    required this.token,
    this.refreshToken,
    this.expiresAt,
    this.devices,
  });
}