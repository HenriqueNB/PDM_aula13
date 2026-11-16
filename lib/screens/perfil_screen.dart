import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/media_service.dart';
import '../services/perfil_service.dart';
import 'foto_visualizacao_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  static const String _heroTag = 'foto-perfil';

  final _mediaService = MediaService();
  final _perfilService = PerfilService();
  final _nomeController = TextEditingController();

  File? _imagemPerfil;
  bool _carregandoImagem = false;
  bool _carregandoPerfil = true;
  Timer? _debounceNome;

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  @override
  void dispose() {
    _debounceNome?.cancel();
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _carregarPerfil() async {
    final nome = await _perfilService.obterNome();
    final caminhoFoto = await _perfilService.obterCaminhoFoto();

    File? foto;
    if (caminhoFoto != null) {
      final arquivo = File(caminhoFoto);
      if (await arquivo.exists()) {
        foto = arquivo;
      } else {
        // O arquivo temporário foi apagado pelo sistema; limpa a referência.
        await _perfilService.removerCaminhoFoto();
      }
    }

    if (!mounted) return;
    setState(() {
      _nomeController.text = nome;
      _imagemPerfil = foto;
      _carregandoPerfil = false;
    });
  }

  Future<void> _selecionarImagem(ImageSource origem) async {
    Navigator.pop(context);
    setState(() => _carregandoImagem = true);

    try {
      final imagem = origem == ImageSource.camera
          ? await _mediaService.tirarFoto()
          : await _mediaService.selecionarDaGaleria();

      if (imagem == null) return;

      await _perfilService.salvarCaminhoFoto(imagem.path);
      if (!mounted) return;
      setState(() => _imagemPerfil = imagem);
    } catch (erro) {
      if (!mounted) return;
      _mostrarMensagem('Não foi possível obter a imagem: $erro');
    } finally {
      if (mounted) setState(() => _carregandoImagem = false);
    }
  }

  Future<void> _removerFoto() async {
    Navigator.pop(context);
    await _perfilService.removerCaminhoFoto();
    if (!mounted) return;
    setState(() => _imagemPerfil = null);
    _mostrarMensagem('Foto de perfil removida.');
  }

  void _salvarNome(String nome) {
    _debounceNome?.cancel();
    _debounceNome = Timer(
      const Duration(milliseconds: 500),
      () => _perfilService.salvarNome(nome),
    );
  }

  void _abrirFoto() {
    final imagem = _imagemPerfil;
    if (imagem == null) return;

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) =>
            FotoVisualizacaoScreen(arquivo: imagem, heroTag: _heroTag),
      ),
    );
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  void _exibirOpcoesMidia() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.pink),
              title: const Text('Tirar Foto com a Câmera'),
              onTap: () => _selecionarImagem(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.pink),
              title: const Text('Escolher da Galeria'),
              onTap: () => _selecionarImagem(ImageSource.gallery),
            ),
            if (_imagemPerfil != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Remover Foto'),
                onTap: _removerFoto,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Usuário'),
        centerTitle: true,
      ),
      body: _carregandoPerfil
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: _abrirFoto,
                          child: Hero(
                            tag: _heroTag,
                            child: CircleAvatar(
                              radius: 70,
                              backgroundColor: Colors.pink.shade100,
                              backgroundImage: _imagemPerfil != null
                                  ? FileImage(_imagemPerfil!)
                                  : null,
                              child: _imagemPerfil == null
                                  ? Icon(
                                      Icons.person,
                                      size: 70,
                                      color: tema.colorScheme.primary,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        if (_carregandoImagem)
                          const Positioned.fill(
                            child: CircleAvatar(
                              backgroundColor: Colors.black38,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: FloatingActionButton.small(
                            onPressed: _exibirOpcoesMidia,
                            tooltip: 'Alterar foto de perfil',
                            child: const Icon(Icons.camera_alt),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _imagemPerfil == null
                        ? 'Nenhuma foto selecionada'
                        : 'Toque na foto para ampliar',
                    style: tema.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nomeController,
                    onChanged: _salvarNome,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nome Completo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: tema.colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            _imagemPerfil == null
                                ? Icons.info_outline
                                : Icons.check_circle_outline,
                            color: _imagemPerfil == null
                                ? tema.colorScheme.primary
                                : Colors.green,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _imagemPerfil == null
                                  ? 'A foto de perfil é opcional e pode ser '
                                        'obtida pela câmera ou galeria.'
                                  : 'O caminho da foto foi salvo no '
                                        'dispositivo e será restaurado ao '
                                        'reabrir o app.',
                              style: tema.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
