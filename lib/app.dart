import 'package:flutter/material.dart';
import 'package:guardians/presentation/views/home.dart';
import 'package:guardians/presentation/views/login.dart';
import 'package:guardians/presentation/views/register.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        "/login": (context) => Login(),
        "/register": (context) => Register(),
        "/home": (context) => Home(),
      },
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      initialRoute: "/login",
    );
  }
}
