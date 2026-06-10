import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardians/presentation/views/home.dart';
import 'package:guardians/services/auth_service.dart';
import 'package:guardians/services/guardiao_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'home_test.mocks.dart';

// Gera os mocks usados pelos testes de widget da Home.
// Rode `dart run build_runner build` para (re)gerar o arquivo .mocks.dart.
@GenerateNiceMocks([
  MockSpec<AuthService>(),
  MockSpec<GuardiaoService>(),
  MockSpec<QuerySnapshot<Map<String, dynamic>>>(as: #MockQuerySnapshot),
  MockSpec<QueryDocumentSnapshot<Map<String, dynamic>>>(
    as: #MockQueryDocumentSnapshot,
  ),
])
void main() {
  late MockAuthService mockAuth;
  late MockGuardiaoService mockGuardiao;

  setUp(() {
    mockAuth = MockAuthService();
    mockGuardiao = MockGuardiaoService();
  });

  // Cria um documento falso do Firestore com os dados informados.
  MockQueryDocumentSnapshot fakeDoc(String id, Map<String, dynamic> data) {
    final doc = MockQueryDocumentSnapshot();
    when(doc.id).thenReturn(id);
    when(doc.data()).thenReturn(data);
    return doc;
  }

  // Empacota uma lista de documentos em um QuerySnapshot falso.
  MockQuerySnapshot snapshotWith(List<MockQueryDocumentSnapshot> docs) {
    final snap = MockQuerySnapshot();
    when(snap.docs).thenReturn(docs);
    return snap;
  }

  // Monta a Home com rotas falsas para validar a navegação de logout.
  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Home(authService: mockAuth, guardiaoService: mockGuardiao),
        routes: {'/login': (_) => const Scaffold(body: Text('LOGIN_FAKE'))},
      ),
    );
  }

  testWidgets('mostra um indicador de progresso enquanto o stream não emite', (
    tester,
  ) async {
    // StreamController sem eventos mantém o StreamBuilder em "waiting".
    final controller =
        StreamController<QuerySnapshot<Map<String, dynamic>>>();
    when(mockGuardiao.stream()).thenAnswer((_) => controller.stream);

    await pumpHome(tester);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await controller.close();
  });

  testWidgets('exibe mensagem de vazio quando não há guardiões', (
    tester,
  ) async {
    when(
      mockGuardiao.stream(),
    ).thenAnswer((_) => Stream.value(snapshotWith([])));

    await pumpHome(tester);
    await tester.pumpAndSettle();

    expect(find.text('Nenhum guardião encontrado.'), findsOneWidget);
  });

  testWidgets('lista os guardiões retornados pelo stream', (tester) async {
    final docs = [
      fakeDoc('1', {
        'service': 'GitHub',
        'user': 'ryan',
        'pass': 'x',
        'icon': 'G',
      }),
      fakeDoc('2', {
        'service': 'Gmail',
        'user': 'ryan@gmail.com',
        'pass': 'y',
        'icon': 'G',
      }),
    ];
    when(
      mockGuardiao.stream(),
    ).thenAnswer((_) => Stream.value(snapshotWith(docs)));

    await pumpHome(tester);
    await tester.pumpAndSettle();

    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('Gmail'), findsOneWidget);
    expect(find.text('ryan'), findsOneWidget);
  });

  testWidgets('o campo de busca filtra a lista pelo nome do serviço', (
    tester,
  ) async {
    final docs = [
      fakeDoc('1', {'service': 'GitHub', 'user': 'ryan', 'icon': 'G'}),
      fakeDoc('2', {'service': 'Gmail', 'user': 'r@g.com', 'icon': 'G'}),
    ];
    when(
      mockGuardiao.stream(),
    ).thenAnswer((_) => Stream.value(snapshotWith(docs)));

    await pumpHome(tester);
    await tester.pumpAndSettle();

    // O primeiro TextField da tela é o campo de busca.
    await tester.enterText(find.byType(TextField).first, 'git');
    // setState reconstrói a Home, que reassina um novo stream; aguarda emitir.
    await tester.pumpAndSettle();

    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('Gmail'), findsNothing);
  });

  testWidgets('o botão flutuante abre o modal de novo guardião', (
    tester,
  ) async {
    when(
      mockGuardiao.stream(),
    ).thenAnswer((_) => Stream.value(snapshotWith([])));

    await pumpHome(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Adicionar Novo Guardião'), findsOneWidget);
  });

  testWidgets('salvar no modal chama GuardiaoService.save com docId nulo', (
    tester,
  ) async {
    when(
      mockGuardiao.stream(),
    ).thenAnswer((_) => Stream.value(snapshotWith([])));
    when(
      mockGuardiao.save(
        service: anyNamed('service'),
        user: anyNamed('user'),
        pass: anyNamed('pass'),
        docId: anyNamed('docId'),
      ),
    ).thenAnswer((_) async {});

    await pumpHome(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Nome'), 'GitHub');
    await tester.enterText(
      find.widgetWithText(TextField, 'Email ou Usuário'),
      'ryan',
    );
    await tester.enterText(find.widgetWithText(TextField, 'Senha'), 'segredo');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar mudanças'));
    await tester.pumpAndSettle();

    verify(
      mockGuardiao.save(
        service: 'GitHub',
        user: 'ryan',
        pass: 'segredo',
        docId: null,
      ),
    ).called(1);
  });

  testWidgets('o botão de logout chama signOut e navega para /login', (
    tester,
  ) async {
    when(
      mockGuardiao.stream(),
    ).thenAnswer((_) => Stream.value(snapshotWith([])));
    when(mockAuth.signOut()).thenAnswer((_) async {});

    await pumpHome(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    verify(mockAuth.signOut()).called(1);
    expect(find.text('LOGIN_FAKE'), findsOneWidget);
  });
}
