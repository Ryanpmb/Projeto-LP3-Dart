import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  /// Realiza o login com e-mail e senha via Firebase.
  /// Exibe um SnackBar de erro caso a autenticação falhe.
  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Login bem-sucedido: redireciona para a tela principal
      if (mounted) Navigator.pushReplacementNamed(context, "/home");

    } on FirebaseAuthException catch (error) {
      // Mapeia os códigos de erro do Firebase para mensagens amigáveis ao usuário
      String errorMessage = 'Ocorreu um erro inesperado. Tente novamente.';

      switch (error.code) {
        case 'invalid-email':
          errorMessage = 'O endereço de e-mail mal formatado.';
          break;
        case 'user-disabled':
          errorMessage = 'Este usuário foi desativado.';
          break;
        case 'user-not-found':
          errorMessage = 'Nenhum usuário encontrado com este e-mail.';
          break;
        case 'wrong-password':
          errorMessage = 'Senha incorreta. Verifique e tente novamente.';
          break;
        case 'email-already-in-use':
          errorMessage = 'Este e-mail já está sendo usado por outra conta.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Esta operação não é permitida.';
          break;
        case 'weak-password':
          errorMessage = 'A senha digitada é muito fraca. Escolha uma senha mais forte.';
          break;
        case 'invalid-credential':
          errorMessage = 'Credenciais inválidas. Verifique seus dados.';
          break;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      // Garante que o loading seja desativado independentemente do resultado
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          // Ocupa a altura total da tela para distribuir os elementos com Spacer
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Abas de navegação entre Login e Registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTabItem("Entrar", isActive: true),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, "/register"),
                    child: _buildTabItem("Registrar-se", isActive: false),
                  ),
                ],
              ),

              const Spacer(),

              // Formulário de login
              Column(
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelText: "E-mail",
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _passwordController,
                    obscureText: true, // Oculta os caracteres da senha
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelText: "Senha",
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    // Exibe um spinner enquanto o login está sendo processado
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Entrar",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                  // Link alternativo para a tela de registro
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                      children: [
                        const TextSpan(text: "Ainda não possui uma conta? "),
                        TextSpan(
                          text: "Registrar-se",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () =>
                                Navigator.pushNamed(context, "/register"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Rodapé com a marca do app
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  "@Guardians",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói uma aba de navegação com indicador visual de estado ativo/inativo.
  Widget _buildTabItem(String label, {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isActive
                ? Colors.lightBlue
                : Colors.lightBlue.withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive
              ? Colors.lightBlue
              : Colors.lightBlue.withOpacity(0.3),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}