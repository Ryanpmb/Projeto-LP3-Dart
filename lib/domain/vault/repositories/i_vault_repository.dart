import '../entities/vault.dart';

abstract interface class IVaultRepository {
  Future<void> create(Vault vault);
  Future<Vault?> findById(String id);
  Future<List<Vault>> findAllByUserId(String userId);
  Future<int> countByUserId(String userId);
  Future<void> update(Vault vault);
  Future<void> delete(String id);
}