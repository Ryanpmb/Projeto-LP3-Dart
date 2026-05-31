import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:guardians/app.dart';
import 'package:guardians/infrastructure/firebase_options.dart';

void main() async {
  // 1. Vincula o Flutter ao motor nativo
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Conecta o app ao projeto Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Inicia a interface do usuário
  runApp(const App());
}