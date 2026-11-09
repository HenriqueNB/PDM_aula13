import 'package:flutter/material.dart';

import 'screens/tarefas_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aula 13 - SQLite',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      home: const TarefasScreen(),
    );
  }
}
