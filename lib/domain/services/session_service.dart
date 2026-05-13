import '../entities/session_entity.dart';
import '../repositories/i_session_repository.dart';

class SessionService {
  final ISessionRepository _repository;

  SessionService(this._repository);

  Future<void> create(SessionEntity session) async {
    if (session.userId.isEmpty) {
      throw ArgumentError('userId não pode ser vazio');
    }

    if (session.token.isEmpty) {
      throw ArgumentError('token não pode ser vazio');
    }

    if (session.expiresAt != null && session.expiresAt!.isBefore(DateTime.now())) {
      throw ArgumentError('A sessão já está expirada');
    }

    await _repository.create(session);
  }

  Future<void> update(SessionEntity session) async {
    if (session.userId.isEmpty) {
      throw ArgumentError('userId não pode ser vazio');
    }

    if (session.token.isEmpty) {
      throw ArgumentError('token não pode ser vazio');
    }

    await _repository.update(session);
  }

  Future<void> delete(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('userId não pode ser vazio');
    }

    await _repository.delete(userId);
  }

  Future<SessionEntity?> findByUserId(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('userId não pode ser vazio');
    }

    return await _repository.findByUserId(userId);
  }
}