import 'dart:convert';
import 'dart:io';

import 'package:app_aula12/screens/foto_visualizacao_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // PNG 1x1 válido para o Image.file conseguir decodificar.
  const png1x1 =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8'
      'z8DwHwAFAAH/q842iQAAAABJRU5ErkJggg==';

  late File arquivo;

  setUpAll(() {
    arquivo = File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}foto_aula15.png',
    );
    arquivo.writeAsBytesSync(base64Decode(png1x1));
  });

  tearDownAll(() {
    if (arquivo.existsSync()) arquivo.deleteSync();
  });

  testWidgets('exibe a foto com Hero e suporte a zoom', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: FotoVisualizacaoScreen(arquivo: arquivo)),
    );
    await tester.pump();

    expect(find.text('Foto do Perfil'), findsOneWidget);
    expect(find.byType(Hero), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);
  });
}
