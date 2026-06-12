import 'package:firebase_auth/firebase_auth.dart';

/// Camada de serviço que encapsula o [FirebaseAuth].
///
/// A instância do Firebase é injetada pelo construtor, permitindo
/// substituí-la por um mock nos testes. Em produção, usa o singleton padrão.
class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  /// Usuário atualmente autenticado, ou `null` se ninguém estiver logado.
  User? get currentUser => _auth.currentUser;

  /// Autentica um usuário com e-mail e senha.
  /// Lança [FirebaseAuthException] em caso de falha.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  /// Cria uma nova conta e define o nome de exibição do usuário.
  /// Lança [FirebaseAuthException] em caso de falha.
  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    // O Firebase não aceita o nome diretamente no cadastro por e-mail/senha,
    // então ele é salvo separadamente após a criação da conta.
    await credential.user?.updateDisplayName(name.trim());

    return credential;
  }

  /// Encerra a sessão do usuário atual.
  Future<void> signOut() => _auth.signOut();

  /// Mapeia os códigos de erro do Firebase para mensagens amigáveis.
  static String messageFromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'O endereço de e-mail mal formatado.';
      case 'user-disabled':
        return 'Este usuário foi desativado.';
      case 'user-not-found':
        return 'Nenhum usuário encontrado com este e-mail.';
      case 'wrong-password':
        return 'Senha incorreta. Verifique e tente novamente.';
      case 'email-already-in-use':
        return 'Este e-mail já está sendo usado por outra conta.';
      case 'operation-not-allowed':
        return 'Esta operação não é permitida.';
      case 'weak-password':
        return 'A senha digitada é muito fraca. Escolha uma senha mais forte.';
      case 'invalid-credential':
        return 'Credenciais inválidas. Verifique seus dados.';
      default:
        return 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }
}
