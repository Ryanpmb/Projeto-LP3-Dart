import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardians/services/guardiao_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'guardiao_service_test.mocks.dart';

// Gera os mocks das classes do Firebase usadas pelo GuardiaoService.
// Rode `dart run build_runner build` para (re)gerar o arquivo .mocks.dart.
@GenerateNiceMocks([
  MockSpec<FirebaseFirestore>(),
  MockSpec<FirebaseAuth>(),
  MockSpec<User>(),
  MockSpec<CollectionReference<Map<String, dynamic>>>(
    as: #MockCollectionReference,
  ),
  MockSpec<DocumentReference<Map<String, dynamic>>>(as: #MockDocumentReference),
  MockSpec<Query<Map<String, dynamic>>>(as: #MockQuery),
  MockSpec<QuerySnapshot<Map<String, dynamic>>>(as: #MockQuerySnapshot),
])
void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;

  // Mocks da cadeia: users -> doc(uid) -> guardioes
  late MockCollectionReference mockUsersCollection;
  late MockDocumentReference mockUserDoc;
  late MockCollectionReference mockGuardioesCollection;

  late GuardiaoService service;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockUsersCollection = MockCollectionReference();
    mockUserDoc = MockDocumentReference();
    mockGuardioesCollection = MockCollectionReference();

    // Usuário autenticado fictício.
    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('uid123');

    // Monta a navegação: users/{uid}/guardioes
    when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(mockUsersCollection.doc('uid123')).thenReturn(mockUserDoc);
    when(
      mockUserDoc.collection('guardioes'),
    ).thenReturn(mockGuardioesCollection);

    service = GuardiaoService(firestore: mockFirestore, auth: mockAuth);
  });

  group('buildData', () {
    test('usa a primeira letra do serviço (maiúscula) como ícone', () {
      final data = service.buildData(
        service: 'gitHub',
        user: 'ryan',
        pass: '123',
      );

      expect(data['service'], 'gitHub');
      expect(data['user'], 'ryan');
      expect(data['pass'], '123');
      expect(data['icon'], 'G');
      expect(data.containsKey('updatedAt'), isTrue);
    });

    test('usa "?" como ícone quando o serviço está vazio', () {
      final data = service.buildData(service: '', user: 'ryan', pass: '123');

      expect(data['icon'], '?');
    });
  });

  group('save', () {
    test('chama add() quando docId é nulo (criação)', () async {
      final mockNewDoc = MockDocumentReference();
      when(
        mockGuardioesCollection.add(any),
      ).thenAnswer((_) async => mockNewDoc);

      await service.save(service: 'GitHub', user: 'ryan', pass: 'segredo');

      final captured =
          verify(mockGuardioesCollection.add(captureAny)).captured.single
              as Map<String, dynamic>;
      expect(captured['service'], 'GitHub');
      expect(captured['user'], 'ryan');
      expect(captured['pass'], 'segredo');
      expect(captured['icon'], 'G');

      // Nunca deve atualizar um documento ao criar.
      verifyNever(mockGuardioesCollection.doc(any));
    });

    test('chama doc().update() quando docId é informado (edição)', () async {
      final mockExistingDoc = MockDocumentReference();
      when(mockGuardioesCollection.doc('doc1')).thenReturn(mockExistingDoc);
      when(mockExistingDoc.update(any)).thenAnswer((_) async {});

      await service.save(
        service: 'GitHub',
        user: 'ryan',
        pass: 'segredo',
        docId: 'doc1',
      );

      final captured =
          verify(mockExistingDoc.update(captureAny)).captured.single
              as Map<String, dynamic>;
      expect(captured['service'], 'GitHub');

      // Nunca deve criar um novo documento ao editar.
      verifyNever(mockGuardioesCollection.add(any));
    });
  });

  group('delete', () {
    test('chama doc(docId).delete()', () async {
      final mockDoc = MockDocumentReference();
      when(mockGuardioesCollection.doc('doc1')).thenReturn(mockDoc);
      when(mockDoc.delete()).thenAnswer((_) async {});

      await service.delete('doc1');

      verify(mockGuardioesCollection.doc('doc1')).called(1);
      verify(mockDoc.delete()).called(1);
    });
  });

  group('stream', () {
    test('ordena por updatedAt (desc) e retorna os snapshots', () async {
      final mockQuery = MockQuery();
      final mockSnapshot = MockQuerySnapshot();
      when(
        mockGuardioesCollection.orderBy('updatedAt', descending: true),
      ).thenReturn(mockQuery);
      when(mockQuery.snapshots()).thenAnswer((_) => Stream.value(mockSnapshot));

      final stream = service.stream();

      await expectLater(stream, emits(mockSnapshot));
      verify(
        mockGuardioesCollection.orderBy('updatedAt', descending: true),
      ).called(1);
    });
  });
}
