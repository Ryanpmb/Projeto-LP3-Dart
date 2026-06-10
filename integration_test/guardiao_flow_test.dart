import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardians/services/auth_service.dart';
import 'package:guardians/services/guardiao_service.dart';
import 'package:integration_test/integration_test.dart';

/// Teste de INTEGRAÇÃO real: usa as instâncias verdadeiras de [FirebaseAuth] e
/// [FirebaseFirestore] apontadas para o Firebase Emulator Suite (sem mocks).
///
/// Pré-requisitos para rodar (veja o README/relatório):
///   1. firebase emulators:start --project demo-guardians --only auth,firestore
///   2. flutter test integration_test/guardiao_flow_test.dart -d chrome
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Projeto "demo-*" faz o emulador rodar em modo offline, sem exigir
    // credenciais reais nem o firebase_options.dart de produção.
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'fake-api-key',
        appId: '1:123456789012:web:fakeappid',
        messagingSenderId: '123456789012',
        projectId: 'demo-guardians',
      ),
    );

    // Redireciona Auth e Firestore para os emuladores locais.
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  });

  testWidgets('registra, persiste e lê um guardião no emulador', (
    tester,
  ) async {
    final authService = AuthService();
    final guardiaoService = GuardiaoService();

    // E-mail único por execução para não colidir com dados anteriores.
    final email = 'user${DateTime.now().millisecondsSinceEpoch}@test.com';

    // 1. Cria a conta de verdade no emulador de Auth.
    await authService.register(
      name: 'Usuário Teste',
      email: email,
      password: 'segredo123',
    );
    expect(authService.currentUser, isNotNull);
    expect(authService.currentUser!.displayName, 'Usuário Teste');

    // 2. Grava um guardião de verdade no emulador do Firestore.
    await guardiaoService.save(
      service: 'GitHub',
      user: 'ryan',
      pass: 'segredo',
    );

    // 3. Lê de volta pelo stream real e valida os dados gravados.
    final snapshot = await guardiaoService.stream().firstWhere(
      (s) => s.docs.isNotEmpty,
    );
    final data = snapshot.docs.first.data();

    expect(snapshot.docs.length, 1);
    expect(data['service'], 'GitHub');
    expect(data['user'], 'ryan');
    expect(data['pass'], 'segredo');
    expect(data['icon'], 'G');

    // 4. Encerra a sessão.
    await authService.signOut();
    expect(authService.currentUser, isNull);
  });

  testWidgets('editar e excluir um guardião pelo serviço real', (tester) async {
    final authService = AuthService();
    final guardiaoService = GuardiaoService();

    final email = 'edit${DateTime.now().millisecondsSinceEpoch}@test.com';
    await authService.register(
      name: 'Editor',
      email: email,
      password: 'segredo123',
    );

    // Cria.
    await guardiaoService.save(service: 'Gmail', user: 'r@g.com', pass: '111');
    var snap = await guardiaoService.stream().firstWhere(
      (s) => s.docs.isNotEmpty,
    );
    final docId = snap.docs.first.id;

    // Edita o mesmo documento.
    await guardiaoService.save(
      service: 'Gmail',
      user: 'novo@g.com',
      pass: '222',
      docId: docId,
    );
    snap = await guardiaoService.stream().first;
    expect(snap.docs.first.data()['user'], 'novo@g.com');
    expect(snap.docs.first.data()['pass'], '222');

    // Exclui.
    await guardiaoService.delete(docId);
    snap = await guardiaoService.stream().first;
    expect(snap.docs, isEmpty);

    await authService.signOut();
  });
}
