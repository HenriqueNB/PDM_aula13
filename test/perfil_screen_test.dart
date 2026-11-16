import 'package:app_aula12/screens/perfil_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('exibe o avatar padrão e o nome inicial', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PerfilScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Perfil do Usuário'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.text('Diego Menegassi'), findsOneWidget);
    expect(find.text('Nenhuma foto selecionada'), findsOneWidget);
  });

  testWidgets('abre o modal com as opções de câmera e galeria', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PerfilScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.camera_alt));
    await tester.pumpAndSettle();

    expect(find.text('Tirar Foto com a Câmera'), findsOneWidget);
    expect(find.text('Escolher da Galeria'), findsOneWidget);
    expect(find.text('Remover Foto'), findsNothing);
  });

  testWidgets('restaura o nome salvo no SharedPreferences', (tester) async {
    SharedPreferences.setMockInitialValues({'perfil_nome': 'Maria Souza'});

    await tester.pumpWidget(const MaterialApp(home: PerfilScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Maria Souza'), findsOneWidget);
  });
}
