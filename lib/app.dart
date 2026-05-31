import 'package:flutter/material.dart';
import 'package:guardians/presentation/views/home.dart';
import 'package:guardians/presentation/views/login.dart';
import 'package:guardians/presentation/views/register.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove a faixa de "Debug" do canto da tela

      // 1. Definição das rotas nomeadas para navegação
      routes: {
        "/login": (context) => Login(),
        "/register": (context) => Register(),
        "/home": (context) => Home(),
      },

      // 2. Configuração global de estilo e cores
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),

      // 3. Define qual tela abrirá primeiro
      initialRoute: "/login",
    );
  }
}