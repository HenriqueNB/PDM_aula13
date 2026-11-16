import 'package:app_aula12/services/perfil_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final service = PerfilService();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('retorna o nome padrão quando nada foi salvo', () async {
    expect(await service.obterNome(), PerfilService.nomePadrao);
  });

  test('salva e recupera o nome do perfil', () async {
    await service.salvarNome('Ana Lima');
    expect(await service.obterNome(), 'Ana Lima');
  });

  test('salva, recupera e remove o caminho da foto', () async {
    await service.salvarCaminhoFoto('/tmp/foto.jpg');
    expect(await service.obterCaminhoFoto(), '/tmp/foto.jpg');

    await service.removerCaminhoFoto();
    expect(await service.obterCaminhoFoto(), isNull);
  });
}
