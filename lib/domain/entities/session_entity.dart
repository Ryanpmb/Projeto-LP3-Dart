class SessionEntity {
  final String userId;
  final String token;
  final String? refreshToken;
  final DateTime? expiresAt;
  final String? devices;

  SessionEntity({
    required this.userId,
    required this.token,
    this.refreshToken,
    this.expiresAt,
    this.devices,
  });
}