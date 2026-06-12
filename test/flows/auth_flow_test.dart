import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardians/presentation/views/home.dart';
import 'package:guardians/presentation/views/login.dart';
import 'package:guardians/presentation/views/register.dart';
import 'package:guardians/services/auth_service.dart';
import 'package:guardians/services/guardiao_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_flow_test.mocks.dart';

// Teste de fluxo (feature): encadeia as telas REAIS por rotas nomeadas,
// usando apenas os serviços mockados, para validar a jornada do usuário.
// Rode `dart run build_runner build` para (re)gerar o arquivo .mocks.dart.
@GenerateNiceMocks([
  MockSpec<AuthService>(),
  MockSpec<GuardiaoService>(),
  MockSpec<UserCredential>(),
  MockSpec<QuerySnapshot<Map<String, dynamic>>>(as: #MockQuerySnapshot),
])
void main() {
  late MockAuthService mockAuth;
  late MockGuardiaoService mockGuardiao;

  setUp(() {
    mockAuth = MockAuthService();
    mockGuardiao = MockGuardiaoService();

    // A Home sempre carrega uma lista vazia de guardiões nestes fluxos.
    final emptySnapshot = MockQuerySnapshot();
    when(emptySnapshot.docs).thenReturn([]);
    when(mockGuardiao.stream()).thenAnswer((_) => Stream.value(emptySnapshot));
  });

  // Monta o app com as três telas reais conectadas pelas mesmas rotas do app.
  Future<void> pumpApp(WidgetTester tester, {String initialRoute = '/login'}) {
    return tester.pumpWidget(
      MaterialApp(
        initialRoute: initialRoute,
        routes: {
          '/login': (_) => Login(authService: mockAuth),
          '/register': (_) => Register(authService: mockAuth),
          '/home': (_) =>
              Home(authService: mockAuth, guardiaoService: mockGuardiao),
        },
      ),
    );
  }

  testWidgets('login bem-sucedido leva o usuário até a Home', (tester) async {
    when(
      mockAuth.signIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ),
    ).thenAnswer((_) async => MockUserCredential());

    await pumpApp(tester);

    await tester.enterText(find.byType(TextField).at(0), 'user@email.com');
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pumpAndSettle();

    // Chegou na Home.
    expect(find.text('Meus Guardiões'), findsOneWidget);
  });

  testWidgets('fluxo de registro: da tela de login ao cadastro e à Home', (
    tester,
  ) async {
    when(
      mockAuth.register(
        name: anyNamed('name'),
        email: anyNamed('email'),
        password: anyNamed('password'),
      ),
    ).thenAnswer((_) async => MockUserCredential());

    await pumpApp(tester);

    // Navega para a tela de registro pela aba.
    await tester.tap(find.text('Registrar-se').first);
    await tester.pumpAndSettle();

    // Preenche o cadastro (4 campos) com senhas coincidentes.
    await tester.enterText(find.byType(TextField).at(0), 'Ryan');
    await tester.enterText(find.byType(TextField).at(1), 'ryan@email.com');
    await tester.enterText(find.byType(TextField).at(2), 'segredo');
    await tester.enterText(find.byType(TextField).at(3), 'segredo');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Registrar-se'));
    await tester.pumpAndSettle();

    expect(find.text('Meus Guardiões'), findsOneWidget);
  });

  testWidgets('jornada completa: login, abrir modal e salvar um guardião', (
    tester,
  ) async {
    when(
      mockAuth.signIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ),
    ).thenAnswer((_) async => MockUserCredential());
    when(
      mockGuardiao.save(
        service: anyNamed('service'),
        user: anyNamed('user'),
        pass: anyNamed('pass'),
        docId: anyNamed('docId'),
      ),
    ).thenAnswer((_) async {});

    await pumpApp(tester);

    // 1. Login
    await tester.enterText(find.byType(TextField).at(0), 'user@email.com');
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pumpAndSettle();

    // 2. Abre o modal de novo guardião
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // 3. Preenche e salva
    await tester.enterText(find.widgetWithText(TextField, 'Nome'), 'GitHub');
    await tester.enterText(
      find.widgetWithText(TextField, 'Email ou Usuário'),
      'ryan',
    );
    await tester.enterText(find.widgetWithText(TextField, 'Senha'), 'segredo');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar mudanças'));
    await tester.pumpAndSettle();

    // O serviço de persistência foi acionado com os dados digitados.
    verify(
      mockGuardiao.save(
        service: 'GitHub',
        user: 'ryan',
        pass: 'segredo',
        docId: null,
      ),
    ).called(1);
  });
}
