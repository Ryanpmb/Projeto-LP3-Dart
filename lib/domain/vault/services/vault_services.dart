import '../repositories/i_vault_repository.dart';
import '../entities/vault.dart';
import '../mappers/mappers.dart';

class VaultService {
  final IVaultRepository _repository;

  VaultService(this._repository);

  Future<void> create(Vault vault) async {
    throw UnimplementedError();
  }

  Future<void> rename(String id, String newName) async {
    throw UnimplementedError();
  }

  Future<void> delete(String id) async {
    throw UnimplementedError();
  }

  Future<List<Vault>> findAllByUserId(String userId) async {
    throw UnimplementedError();
  }

  Future<int> countByUserId(String userId) async {
    throw UnimplementedError();
  }
}