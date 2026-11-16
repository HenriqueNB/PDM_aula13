import 'package:geolocator/geolocator.dart';

/// Coordenadas aproximadas da Fatec Matão - Luiz Marchesan.
const double fatecMataoLatitude = -21.62067;
const double fatecMataoLongitude = -48.36035;

enum NivelPrecisao { excelente, media, baixa }

/// Classifica a precisão do GPS em faixas visuais.
NivelPrecisao classificarPrecisao(double precisaoMetros) {
  if (precisaoMetros < 15) {
    return NivelPrecisao.excelente;
  }
  if (precisaoMetros <= 50) {
    return NivelPrecisao.media;
  }
  return NivelPrecisao.baixa;
}

/// Formata a distância em metros ou quilômetros.
String formatarDistancia(double metros) {
  if (metros >= 1000) {
    final quilometros = (metros / 1000).toStringAsFixed(2).replaceAll('.', ',');
    return '$quilometros km';
  }
  return '${metros.toStringAsFixed(0)} m';
}

/// Calcula a distância, em metros, entre a posição atual e a Fatec Matão.
double calcularDistanciaAteFatec(Position posicao) {
  return Geolocator.distanceBetween(
    posicao.latitude,
    posicao.longitude,
    fatecMataoLatitude,
    fatecMataoLongitude,
  );
}
