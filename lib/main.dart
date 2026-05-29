import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:guardians/app.dart';
import 'package:guardians/infrastructure/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}
