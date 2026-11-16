import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/location_service.dart';
import '../utils/geo_utils.dart';

class GeolocalizacaoScreen extends StatefulWidget {
  const GeolocalizacaoScreen({super.key});

  @override
  State<GeolocalizacaoScreen> createState() => _GeolocalizacaoScreenState();
}

class _GeolocalizacaoScreenState extends State<GeolocalizacaoScreen> {
  final _locationService = LocationService();

  Position? _posicaoAtual;
  bool _carregando = false;
  String? _mensagemErro;
  bool _permissaoNegadaPermanentemente = false;
  StreamSubscription<Position>? _positionStreamSub;
  bool _rastreando = false;

  @override
  void dispose() {
    _positionStreamSub?.cancel();
    super.dispose();
  }

  Future<void> _buscarLocalizacao() async {
    setState(() {
      _carregando = true;
      _mensagemErro = null;
      _permissaoNegadaPermanentemente = false;
    });

    try {
      final posicao = await _locationService.obterPosicaoAtual();
      if (!mounted) return;
      setState(() => _posicaoAtual = posicao);
    } catch (erro) {
      if (!mounted) return;
      setState(() {
        _mensagemErro = _limparMensagemErro(erro);
        _permissaoNegadaPermanentemente =
            _mensagemErro!.contains('permanentemente');
      });
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _alternarRastreamento() async {
    if (_rastreando) {
      await _positionStreamSub?.cancel();
      if (!mounted) return;
      setState(() {
        _rastreando = false;
        _positionStreamSub = null;
      });
      return;
    }

    setState(() {
      _carregando = true;
      _mensagemErro = null;
      _permissaoNegadaPermanentemente = false;
    });

    try {
      await _locationService.garantirPermissoes();
      if (!mounted) return;

      setState(() {
        _rastreando = true;
        _carregando = false;
      });

      _positionStreamSub = _locationService.monitorarPosicao().listen(
        (posicao) {
          if (!mounted) return;
          setState(() => _posicaoAtual = posicao);
        },
        onError: (erro) {
          if (!mounted) return;
          setState(() {
            _mensagemErro = _limparMensagemErro(erro);
            _rastreando = false;
          });
          _positionStreamSub?.cancel();
        },
      );
    } catch (erro) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
        _rastreando = false;
        _mensagemErro = _limparMensagemErro(erro);
        _permissaoNegadaPermanentemente =
            _mensagemErro!.contains('permanentemente');
      });
    }
  }

  Future<void> _abrirNoMapa() async {
    final posicao = _posicaoAtual;
    if (posicao == null) return;

    final uri = Uri.parse(
      'https://maps.google.com/?q=${posicao.latitude},${posicao.longitude}',
    );

    try {
      final abriu = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!abriu) {
        throw Exception('Não foi possível abrir o Google Maps.');
      }
    } catch (erro) {
      if (!mounted) return;
      _mostrarMensagem('Falha ao abrir o mapa: ${_limparMensagemErro(erro)}');
    }
  }

  String _limparMensagemErro(Object erro) {
    return erro.toString().replaceFirst('Exception: ', '');
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in & GPS'),
        centerTitle: true,
        actions: [
          if (_rastreando)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                avatar: const Icon(
                  Icons.circle,
                  size: 10,
                  color: Colors.green,
                ),
                label: const Text('AO VIVO'),
                labelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                backgroundColor: Colors.green.withValues(alpha: 0.12),
                side: BorderSide.none,
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    if (_carregando) ...[
                      const LinearProgressIndicator(),
                      const SizedBox(height: 12),
                    ],
                    if (_mensagemErro != null) ...[
                      _construirCardErro(),
                      const SizedBox(height: 12),
                    ],
                    if (_posicaoAtual != null)
                      _construirCardPosicao(_posicaoAtual!)
                    else if (!_carregando && _mensagemErro == null)
                      _construirEstadoInicial(tema),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _carregando ? null : _buscarLocalizacao,
                  icon: const Icon(Icons.gps_fixed),
                  label: const Text('Capturar Localização Atual'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _carregando ? null : _alternarRastreamento,
                  icon: Icon(_rastreando ? Icons.stop : Icons.play_arrow),
                  label: Text(
                    _rastreando
                        ? 'Parar Rastreamento'
                        : 'Iniciar Rastreamento Contínuo',
                  ),
                ),
              ),
              if (_posicaoAtual != null) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _abrirNoMapa,
                    icon: const Icon(Icons.map),
                    label: const Text('Abrir no Google Maps'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirEstadoInicial(ThemeData tema) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.location_searching,
              size: 64,
              color: tema.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            const Text(
              'Nenhuma localização capturada',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Toque em "Capturar Localização Atual" para obter latitude, '
              'longitude e precisão do GPS.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirCardErro() {
    final erroDeGps = _mensagemErro!.contains('GPS');

    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _mensagemErro!,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              ],
            ),
            if (_permissaoNegadaPermanentemente)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _locationService.abrirConfiguracoes(),
                  icon: const Icon(Icons.settings),
                  label: const Text('Abrir configurações'),
                ),
              )
            else if (erroDeGps)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () =>
                      _locationService.abrirConfiguracoesLocalizacao(),
                  icon: const Icon(Icons.location_on),
                  label: const Text('Ativar GPS'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _construirCardPosicao(Position posicao) {
    final nivel = classificarPrecisao(posicao.accuracy);
    final distancia = calcularDistanciaAteFatec(posicao);

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Coordenadas capturadas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _construirChipPrecisao(nivel, posicao.accuracy),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.my_location, color: Colors.blue),
            title: const Text('Latitude'),
            subtitle: Text(posicao.latitude.toStringAsFixed(6)),
          ),
          ListTile(
            leading: const Icon(Icons.location_on, color: Colors.green),
            title: const Text('Longitude'),
            subtitle: Text(posicao.longitude.toStringAsFixed(6)),
          ),
          ListTile(
            leading: const Icon(Icons.speed, color: Colors.orange),
            title: const Text('Precisão / Altitude'),
            subtitle: Text(
              'Precisão: ${posicao.accuracy.toStringAsFixed(1)} m | '
              'Alt: ${posicao.altitude.toStringAsFixed(1)} m',
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.school, color: Colors.purple),
            title: const Text('Distância até a Fatec Matão'),
            subtitle: Text(formatarDistancia(distancia)),
            trailing: const Icon(Icons.flag_outlined),
          ),
        ],
      ),
    );
  }

  Widget _construirChipPrecisao(NivelPrecisao nivel, double precisao) {
    late final Color cor;
    late final String rotulo;
    late final IconData icone;

    switch (nivel) {
      case NivelPrecisao.excelente:
        cor = Colors.green;
        rotulo = 'Excelente';
        icone = Icons.gps_fixed;
      case NivelPrecisao.media:
        cor = Colors.orange;
        rotulo = 'Média';
        icone = Icons.gps_not_fixed;
      case NivelPrecisao.baixa:
        cor = Colors.red;
        rotulo = 'Baixa';
        icone = Icons.gps_off;
    }

    return Chip(
      avatar: Icon(icone, size: 18, color: cor),
      label: Text('$rotulo • ${precisao.toStringAsFixed(1)} m'),
      labelStyle: TextStyle(
        color: cor,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      backgroundColor: cor.withValues(alpha: 0.12),
      side: BorderSide(color: cor.withValues(alpha: 0.4)),
      visualDensity: VisualDensity.compact,
    );
  }
}
