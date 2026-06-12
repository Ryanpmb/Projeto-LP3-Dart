import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardians/services/auth_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_service_test.mocks.dart';

// Gera os mocks das classes do Firebase usadas pelo AuthService.
// Rode `dart run build_runner build` para (re)gerar o arquivo .mocks.dart.
@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(),
  MockSpec<UserCredential>(),
  MockSpec<User>(),
])
void main() {
  late MockFirebaseAuth mockAuth;
  late AuthService service;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    service = AuthService(auth: mockAuth);
  });

  group('signIn', () {
    test('chama signInWithEmailAndPassword com e-mail e senha "trimados"', () async {
      final mockCredential = MockUserCredential();
      when(
        mockAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => mockCredential);

      final result = await service.signIn(
        email: '  user@email.com  ',
        password: '  123456  ',
      );

      expect(result, mockCredential);
      verify(
        mockAuth.signInWithEmailAndPassword(
          email: 'user@email.com',
          password: '123456',
        ),
      ).called(1);
    });

    test('propaga FirebaseAuthException quando o login falha', () async {
      when(
        mockAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      expect(
        () => service.signIn(email: 'a@b.com', password: 'x'),
        throwsA(
          isA<FirebaseAuthException>().having(
            (e) => e.code,
            'code',
            'wrong-password',
          ),
        ),
      );
    });
  });

  group('register', () {
    test('cria a conta e atualiza o nome de exibição', () async {
      final mockCredential = MockUserCredential();
      final mockUser = MockUser();
      when(mockCredential.user).thenReturn(mockUser);
      when(
        mockAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => mockCredential);

      final result = await service.register(
        name: '  Ryan  ',
        email: '  ryan@email.com  ',
        password: '  segredo  ',
      );

      expect(result, mockCredential);
      verify(
        mockAuth.createUserWithEmailAndPassword(
          email: 'ryan@email.com',
          password: 'segredo',
        ),
      ).called(1);
      // O nome também deve ser "trimado" e propagado para o usuário criado.
      verify(mockUser.updateDisplayName('Ryan')).called(1);
    });

    test('não quebra quando o usuário criado é nulo', () async {
      final mockCredential = MockUserCredential();
      when(mockCredential.user).thenReturn(null);
      when(
        mockAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => mockCredential);

      final result = await service.register(
        name: 'Ryan',
        email: 'ryan@email.com',
        password: 'segredo',
      );

      expect(result, mockCredential);
    });
  });

  group('signOut e currentUser', () {
    test('signOut delega para o FirebaseAuth', () async {
      when(mockAuth.signOut()).thenAnswer((_) async {});

      await service.signOut();

      verify(mockAuth.signOut()).called(1);
    });

    test('currentUser retorna o usuário do FirebaseAuth', () {
      final mockUser = MockUser();
      when(mockAuth.currentUser).thenReturn(mockUser);

      expect(service.currentUser, mockUser);
    });
  });

  group('messageFromCode', () {
    test('mapeia códigos conhecidos para mensagens amigáveis', () {
      expect(
        AuthService.messageFromCode('wrong-password'),
        'Senha incorreta. Verifique e tente novamente.',
      );
      expect(
        AuthService.messageFromCode('email-already-in-use'),
        'Este e-mail já está sendo usado por outra conta.',
      );
      expect(
        AuthService.messageFromCode('invalid-email'),
        'O endereço de e-mail mal formatado.',
      );
    });

    test('retorna mensagem genérica para código desconhecido', () {
      expect(
        AuthService.messageFromCode('codigo-inexistente'),
        'Ocorreu um erro inesperado. Tente novamente.',
      );
    });
  });
}
