import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardians/presentation/views/register.dart';
import 'package:guardians/services/auth_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'register_test.mocks.dart';

// Gera os mocks usados pelos testes de widget da tela de Registro.
// Rode `dart run build_runner build` para (re)gerar o arquivo .mocks.dart.
@GenerateNiceMocks([MockSpec<AuthService>(), MockSpec<UserCredential>()])
void main() {
  late MockAuthService mockAuth;

  setUp(() {
    mockAuth = MockAuthService();
  });

  // Monta a tela de Registro dentro de um MaterialApp com rotas falsas.
  Future<void> pumpRegister(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Register(authService: mockAuth),
        routes: {
          '/home': (_) => const Scaffold(body: Text('HOME_FAKE')),
          '/login': (_) => const Scaffold(body: Text('LOGIN_FAKE')),
        },
      ),
    );
  }

  testWidgets('renderiza todos os campos do formulário de cadastro', (
    tester,
  ) async {
    await pumpRegister(tester);

    expect(find.text('Nome'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Repita a senha'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Registrar-se'), findsOneWidget);
  });

  testWidgets('mostra erro e não chama register quando as senhas divergem', (
    tester,
  ) async {
    await pumpRegister(tester);

    await tester.enterText(find.byType(TextField).at(0), 'Ryan'); // Nome
    await tester.enterText(find.byType(TextField).at(1), 'r@e.com'); // E-mail
    await tester.enterText(find.byType(TextField).at(2), '123456'); // Senha
    await tester.enterText(find.byType(TextField).at(3), '654321'); // Repetir

    await tester.tap(find.widgetWithText(ElevatedButton, 'Registrar-se'));
    await tester.pump();

    expect(find.text('As senhas não coincidem'), findsOneWidget);
    verifyNever(
      mockAuth.register(
        name: anyNamed('name'),
        email: anyNamed('email'),
        password: anyNamed('password'),
      ),
    );
  });

  testWidgets('cadastra e navega para /home quando as senhas coincidem', (
    tester,
  ) async {
    when(
      mockAuth.register(
        name: anyNamed('name'),
        email: anyNamed('email'),
        password: anyNamed('password'),
      ),
    ).thenAnswer((_) async => MockUserCredential());

    await pumpRegister(tester);

    await tester.enterText(find.byType(TextField).at(0), 'Ryan');
    await tester.enterText(find.byType(TextField).at(1), 'ryan@email.com');
    await tester.enterText(find.byType(TextField).at(2), 'segredo');
    await tester.enterText(find.byType(TextField).at(3), 'segredo');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Registrar-se'));
    await tester.pumpAndSettle();

    verify(
      mockAuth.register(
        name: 'Ryan',
        email: 'ryan@email.com',
        password: 'segredo',
      ),
    ).called(1);
    expect(find.text('HOME_FAKE'), findsOneWidget);
  });

  testWidgets('exibe SnackBar amigável quando o Firebase rejeita o cadastro', (
    tester,
  ) async {
    when(
      mockAuth.register(
        name: anyNamed('name'),
        email: anyNamed('email'),
        password: anyNamed('password'),
      ),
    ).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

    await pumpRegister(tester);

    await tester.enterText(find.byType(TextField).at(0), 'Ryan');
    await tester.enterText(find.byType(TextField).at(1), 'ryan@email.com');
    await tester.enterText(find.byType(TextField).at(2), 'segredo');
    await tester.enterText(find.byType(TextField).at(3), 'segredo');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Registrar-se'));
    await tester.pump();
    await tester.pump();

    expect(
      find.text('Este e-mail já está sendo usado por outra conta.'),
      findsOneWidget,
    );
    expect(find.text('HOME_FAKE'), findsNothing);
  });
}
