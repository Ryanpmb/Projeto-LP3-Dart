import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _isObscure = true;
  String _searchQuery = '';

  /// Salva ou atualiza um guardião no Firestore.
  /// Se [docId] for nulo, cria um novo documento; caso contrário, atualiza o existente.
  Future<void> _handleSave(String? docId) async {
    final String uid = _auth.currentUser!.uid;
    final data = {
      "service": _serviceController.text,
      "user": _userController.text,
      "pass": _passController.text,
      // Usa a primeira letra do serviço como ícone, ou "?" se o campo estiver vazio
      "icon": _serviceController.text.isNotEmpty
          ? _serviceController.text[0].toUpperCase()
          : "?",
      "updatedAt": FieldValue.serverTimestamp(),
    };

    if (docId == null) {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('guardioes')
          .add(data);
    } else {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('guardioes')
          .doc(docId)
          .update(data);
    }
  }

  /// Remove permanentemente um guardião do Firestore pelo seu [docId].
  Future<void> _handleDelete(String docId) async {
    final String uid = _auth.currentUser!.uid;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('guardioes')
        .doc(docId)
        .delete();
  }

  /// Exibe o modal de criação ou edição de um guardião.
  /// Em modo de edição, pré-preenche os campos com os dados existentes.
  void _showPasswordModal({
    Map<String, dynamic>? initialData,
    String? docId,
    bool isEdit = false,
  }) {
    if (isEdit && initialData != null) {
      _serviceController.text = initialData['service'] ?? '';
      _userController.text = initialData['user'] ?? '';
      _passController.text = initialData['pass'] ?? '';
    } else {
      _serviceController.clear();
      _userController.clear();
      _passController.clear();
    }

    _isObscure = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // StatefulBuilder permite atualizar o estado interno do modal
        // sem precisar reconstruir o widget pai (necessário para o toggle de senha)
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              // Ajusta o padding para que o modal suba com o teclado
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: SizedBox(width: 40, child: Divider(thickness: 4)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? "Editar Guardião" : "Adicionar Novo Guardião",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      // Botão de exclusão visível apenas no modo de edição
                      if (isEdit)
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            _handleDelete(docId!);
                            Navigator.pop(context);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildTextField("Nome", Icons.apps, _serviceController),
                  const SizedBox(height: 15),
                  _buildTextField(
                    "Email ou Usuário",
                    Icons.person_outline,
                    _userController,
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _passController,
                    obscureText: _isObscure,
                    decoration: InputDecoration(
                      labelText: "Senha",
                      prefixIcon: const Icon(Icons.lock_outline),
                      // Botão para alternar visibilidade da senha dentro do modal
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscure ? Icons.visibility_off : Icons.visibility,
                          color: Colors.blue,
                        ),
                        onPressed: () =>
                            setModalState(() => _isObscure = !_isObscure),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () async {
                      await _handleSave(docId);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isEdit ? "Atualizar" : "Salvar mudanças",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Atalho para construir campos de texto padronizados com ícone.
  Widget _buildTextField(
    String label,
    IconData icon,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String uid = _auth.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Meus Guardiões",
          style: TextStyle(
            color: Colors.blue,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Botão de logout: encerra a sessão e retorna para a tela de login
          IconButton(
            onPressed: () async {
              await _auth.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, "/login");
              }
            },
            icon: const Icon(Icons.logout, color: Colors.blue),
          ),
        ],
      ),
      body: Column(
        children: [
          // Campo de busca: filtra a lista em tempo real pelo nome do serviço
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Procurar guardião...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            // StreamBuilder escuta as mudanças no Firestore em tempo real,
            // atualizando a lista automaticamente sem necessidade de recarregar
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(uid)
                  .collection('guardioes')
                  .orderBy('updatedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allDocs = snapshot.data?.docs ?? [];

                // Filtra os documentos pelo serviço com base na busca digitada
                final filteredDocs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final service = (data['service'] ?? "")
                      .toString()
                      .toLowerCase();
                  return service.contains(_searchQuery.toLowerCase());
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(
                    child: Text("Nenhum guardião encontrado."),
                  );
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final item = doc.data() as Map<String, dynamic>;
                    final String docId = doc.id;

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade50,
                          child: Text(
                            item["icon"] ?? "G",
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          item["service"] ?? "",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(item["user"] ?? ""),
                        trailing: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                        // Abre o modal de edição ao tocar no card
                        onTap: () => _showPasswordModal(
                          initialData: item,
                          docId: docId,
                          isEdit: true,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Botão para abrir o modal de criação de um novo guardião
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPasswordModal(isEdit: false),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}