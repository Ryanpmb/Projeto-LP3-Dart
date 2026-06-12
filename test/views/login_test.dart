import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardians/presentation/views/login.dart';
import 'package:guardians/services/auth_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'login_test.mocks.dart';

// Gera os mocks usados pelos testes de widget da tela de Login.
// Rode `dart run build_runner build` para (re)gerar o arquivo .mocks.dart.
@GenerateNiceMocks([MockSpec<AuthService>(), MockSpec<UserCredential>()])
void main() {
  late MockAuthService mockAuth;

  setUp(() {
    mockAuth = MockAuthService();
  });

  // Monta a tela de Login dentro de um MaterialApp com rotas falsas,
  // permitindo verificar a navegação sem precisar das telas reais.
  Future<void> pumpLogin(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Login(authService: mockAuth),
        routes: {
          '/home': (_) => const Scaffold(body: Text('HOME_FAKE')),
          '/register': (_) => const Scaffold(body: Text('REGISTER_FAKE')),
        },
      ),
    );
  }

  testWidgets('renderiza os campos de e-mail, senha e o botão Entrar', (
    tester,
  ) async {
    await pumpLogin(tester);

    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
  });

  testWidgets('não chama signIn quando os campos estão vazios', (tester) async {
    await pumpLogin(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pump();

    verifyNever(
      mockAuth.signIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ),
    );
  });

  testWidgets('faz login e navega para /home em caso de sucesso', (
    tester,
  ) async {
    when(
      mockAuth.signIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ),
    ).thenAnswer((_) async => MockUserCredential());

    await pumpLogin(tester);

    await tester.enterText(find.byType(TextField).at(0), 'user@email.com');
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pumpAndSettle();

    verify(
      mockAuth.signIn(email: 'user@email.com', password: '123456'),
    ).called(1);
    expect(find.text('HOME_FAKE'), findsOneWidget);
  });

  testWidgets('exibe SnackBar com mensagem amigável quando o login falha', (
    tester,
  ) async {
    when(
      mockAuth.signIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ),
    ).thenThrow(FirebaseAuthException(code: 'wrong-password'));

    await pumpLogin(tester);

    await tester.enterText(find.byType(TextField).at(0), 'a@b.com');
    await tester.enterText(find.byType(TextField).at(1), 'errada');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pump(); // dispara o _handleLogin
    await tester.pump(); // renderiza o SnackBar

    expect(
      find.text('Senha incorreta. Verifique e tente novamente.'),
      findsOneWidget,
    );
    // Permaneceu na tela de Login (não navegou).
    expect(find.text('HOME_FAKE'), findsNothing);
  });

  testWidgets('navega para /register ao tocar na aba Registrar-se', (
    tester,
  ) async {
    await pumpLogin(tester);

    // A primeira ocorrência de "Registrar-se" é a aba superior.
    await tester.tap(find.text('Registrar-se').first);
    await tester.pumpAndSettle();

    expect(find.text('REGISTER_FAKE'), findsOneWidget);
  });
}
