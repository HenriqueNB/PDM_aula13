import 'dart:async';

import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Verifica se o GPS está ligado e se o app possui permissão de localização.
  Future<void> garantirPermissoes() async {
    final servicoHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicoHabilitado) {
      throw Exception('O serviço de GPS está desativado no dispositivo.');
    }

    var permissao = await Geolocator.checkPermission();

    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    if (permissao == LocationPermission.denied) {
      throw Exception('Permissão de localização negada pelo usuário.');
    }

    if (permissao == LocationPermission.deniedForever) {
      throw Exception(
        'Permissões negadas permanentemente. Altere nas configurações.',
      );
    }
  }

  /// Captura uma única posição com alta precisão.
  Future<Position> obterPosicaoAtual() async {
    await garantirPermissoes();

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
    } on TimeoutException {
      // Em emuladores o GPS pode demorar a emitir um novo fix.
      final ultimaPosicao = await Geolocator.getLastKnownPosition();
      if (ultimaPosicao != null) {
        return ultimaPosicao;
      }
      rethrow;
    }
  }

  /// Emite novas posições conforme o usuário se desloca.
  Stream<Position> monitorarPosicao() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  Future<bool> abrirConfiguracoes() {
    return Geolocator.openAppSettings();
  }

  Future<bool> abrirConfiguracoesLocalizacao() {
    return Geolocator.openLocationSettings();
  }
}
