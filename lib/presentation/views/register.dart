import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  bool _isLoading = false;

  /// Cria uma nova conta com e-mail e senha via Firebase,
  /// e atualiza o nome de exibição do usuário após o cadastro.
  Future<void> _handleRegister() async {
    // Valida se as senhas coincidem antes de chamar a API
    if (_passwordController.text != _repeatPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("As senhas não coincidem"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // Salva o nome de exibição separadamente, pois o Firebase
      // não aceita o nome diretamente no cadastro por e-mail/senha
      await user.user?.updateDisplayName(_nameController.text.trim());

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
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, "/login"),
                    child: _buildTabItem("Entrar", isActive: false),
                  ),
                  const SizedBox(width: 15),
                  _buildTabItem("Registrar-se", isActive: true),
                ],
              ),

              const Spacer(),

              // Formulário de cadastro
              Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelText: "Nome",
                    ),
                  ),
                  const SizedBox(height: 15),
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
                  const SizedBox(height: 15),
                  TextField(
                    controller: _repeatPasswordController,
                    obscureText: true, // Oculta os caracteres da confirmação
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelText: "Repita a senha",
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    // Exibe um spinner enquanto o cadastro está sendo processado
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
                            "Registrar-se",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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