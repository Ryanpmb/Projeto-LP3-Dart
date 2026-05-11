import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:guardians/domain/cofre/entities/vault.dart';
import 'package:guardians/domain/cofre/repositories/i_vault_repository.dart';
import 'package:guardians/domain/cofre/services/vault_service.dart';

@GenerateMocks([IVaultRepository])
import 'vault_service_test.mocks.dart';

void main() {
  late VaultService service;
  late MockIVaultRepository mockRepository;

  setUp(() {
    mockRepository = MockIVaultRepository();
    service = VaultService(mockRepository);
  });

  group('VaultService.create', () {
    test('deve criar um cofre com sucesso', () async {
      final vault = Vault(
        id: '1',
        userId: 'user1',
        name: 'Pessoal',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockRepository.countByUserId('user1')).thenAnswer((_) async => 0);
      when(mockRepository.create(vault)).thenAnswer((_) async {});

      await service.create(vault);

      verify(mockRepository.create(vault)).called(1);
    });

    test('deve lançar exceção se nome tiver mais de 30 caracteres', () async {
      final vault = Vault(
        id: '1',
        userId: 'user1',
        name: 'a' * 31,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(() => service.create(vault), throwsException);
    });

    test('deve lançar exceção se usuário já tiver 10 cofres', () async {
      final vault = Vault(
        id: '1',
        userId: 'user1',
        name: 'Pessoal',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockRepository.countByUserId('user1')).thenAnswer((_) async => 10);

      expect(() => service.create(vault), throwsException);
    });
  });

  group('VaultService.rename', () {
    test('deve renomear com sucesso', () async {
      final vault = Vault(
        id: '1',
        userId: 'user1',
        name: 'Pessoal',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockRepository.findById('1')).thenAnswer((_) async => vault);
      when(mockRepository.update(any)).thenAnswer((_) async {});

      await service.rename('1', 'Novo Nome');

      verify(mockRepository.update(any)).called(1);
    });

    test('deve lançar exceção se novo nome tiver mais de 30 caracteres', () async {
      expect(() => service.rename('1', 'a' * 31), throwsException);
    });
  });

  group('VaultService.delete', () {
    test('deve deletar com sucesso', () async {
      when(mockRepository.delete('1')).thenAnswer((_) async {});

      await service.delete('1');

      verify(mockRepository.delete('1')).called(1);
    });
  });

  group('VaultService.findAllByUserId', () {
    test('deve retornar todos os cofres do usuário', () async {
      final vaults = [
        Vault(id: '1', userId: 'user1', name: 'Pessoal', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        Vault(id: '2', userId: 'user1', name: 'Trabalho', createdAt: DateTime.now(), updatedAt: DateTime.now()),
      ];

      when(mockRepository.findAllByUserId('user1')).thenAnswer((_) async => vaults);

      final result = await service.findAllByUserId('user1');

      expect(result, vaults);
    });
  });

  group('VaultService.countByUserId', () {
    test('deve retornar a quantidade correta de cofres', () async {
      when(mockRepository.countByUserId('user1')).thenAnswer((_) async => 3);

      final result = await service.countByUserId('user1');

      expect(result, 3);
    });
  });
}