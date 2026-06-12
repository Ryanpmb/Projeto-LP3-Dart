import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Camada de serviço que encapsula o acesso aos "guardiões" no Firestore.
///
/// As instâncias do Firebase são injetadas pelo construtor, permitindo
/// substituí-las por mocks nos testes.
class GuardiaoService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  GuardiaoService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  /// Referência para a subcoleção de guardiões do usuário autenticado.
  CollectionReference<Map<String, dynamic>> _guardioes() {
    final uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).collection('guardioes');
  }

  /// Monta o mapa de dados de um guardião.
  ///
  /// O ícone é a primeira letra do serviço em maiúsculo, ou "?" se vazio.
  /// Método público e puro para facilitar a verificação em testes.
  Map<String, dynamic> buildData({
    required String service,
    required String user,
    required String pass,
  }) {
    return {
      'service': service,
      'user': user,
      'pass': pass,
      'icon': service.isNotEmpty ? service[0].toUpperCase() : '?',
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Cria um novo guardião (quando [docId] é nulo) ou atualiza um existente.
  Future<void> save({
    required String service,
    required String user,
    required String pass,
    String? docId,
  }) {
    final data = buildData(service: service, user: user, pass: pass);
    final collection = _guardioes();

    if (docId == null) {
      return collection.add(data);
    }
    return collection.doc(docId).update(data);
  }

  /// Remove permanentemente um guardião pelo seu [docId].
  Future<void> delete(String docId) {
    return _guardioes().doc(docId).delete();
  }

  /// Stream em tempo real dos guardiões, ordenados pela última atualização.
  Stream<QuerySnapshot<Map<String, dynamic>>> stream() {
    return _guardioes().orderBy('updatedAt', descending: true).snapshots();
  }
}
