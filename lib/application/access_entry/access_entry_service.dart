import '../../domain/access_entry/entities/access_entry.dart';
import '../../domain/access_entry/repositories/i_access_entry_repository.dart';

class AccessEntryService {
  final IAccessEntryRepository _repository;

  AccessEntryService(this._repository);

  Future<void> create(AccessEntry accessEntry) async {
    throw UnimplementedError();
  }

  Future<void> update(AccessEntry accessEntry) async {
    throw UnimplementedError();
  }

  Future<void> delete(String id) async {
    throw UnimplementedError();
  }

  Future<AccessEntry?> findById(String id) async {
    throw UnimplementedError();
  }

  Future<List<AccessEntry>> findAllByUserId(String userId) async {
    throw UnimplementedError();
  }

  Future<int> countByUserId(String userId) async {
    throw UnimplementedError();
  }
}