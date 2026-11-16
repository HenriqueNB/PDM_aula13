import 'package:flutter/material.dart';

import 'screens/geolocalizacao_screen.dart';

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
      title: 'Aula 14 - GPS',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.lightBlue,
      ),
      home: const GeolocalizacaoScreen(),
    );
  }
}
