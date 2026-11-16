import 'package:app_aula12/screens/geolocalizacao_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('exibe o estado inicial da tela de geolocalização', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: GeolocalizacaoScreen()),
    );

    expect(find.text('Check-in & GPS'), findsOneWidget);
    expect(find.text('Nenhuma localização capturada'), findsOneWidget);
    expect(find.text('Capturar Localização Atual'), findsOneWidget);
    expect(find.text('Iniciar Rastreamento Contínuo'), findsOneWidget);
    expect(find.text('Abrir no Google Maps'), findsNothing);
  });
}
