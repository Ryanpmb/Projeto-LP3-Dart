import 'package:guardians/domain/entities/session_entity.dart';

abstract class ISessionRepository {
  Future<void> create(SessionEntity session);
  Future<void> update(SessionEntity session);
  Future<void> delete(String userId);
  Future<SessionEntity?> findByUserId(String userId);
}