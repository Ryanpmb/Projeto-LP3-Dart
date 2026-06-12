import '../entities/access_entry.dart';

abstract interface class IAccessEntryRepository {
  Future<void> create(AccessEntry accessEntry);
  Future<AccessEntry?> findById(String id);
  Future<List<AccessEntry>> findAllByUserId(String userId);
  Future<int> countByUserId(String userId);
  Future<void> update(AccessEntry accessEntry);
  Future<void> delete(String id);
}