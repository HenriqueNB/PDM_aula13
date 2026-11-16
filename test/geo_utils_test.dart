import 'package:app_aula12/utils/geo_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('classificarPrecisao', () {
    test('precisão menor que 15 m é excelente', () {
      expect(classificarPrecisao(0), NivelPrecisao.excelente);
      expect(classificarPrecisao(14.9), NivelPrecisao.excelente);
    });

    test('precisão entre 15 m e 50 m é média', () {
      expect(classificarPrecisao(15), NivelPrecisao.media);
      expect(classificarPrecisao(50), NivelPrecisao.media);
    });

    test('precisão maior que 50 m é baixa', () {
      expect(classificarPrecisao(50.1), NivelPrecisao.baixa);
      expect(classificarPrecisao(120), NivelPrecisao.baixa);
    });
  });

  group('formatarDistancia', () {
    test('mantém metros quando a distância é menor que 1 km', () {
      expect(formatarDistancia(0), '0 m');
      expect(formatarDistancia(999.4), '999 m');
    });

    test('converte para quilômetros com vírgula decimal', () {
      expect(formatarDistancia(1000), '1,00 km');
      expect(formatarDistancia(1250), '1,25 km');
    });
  });
}
