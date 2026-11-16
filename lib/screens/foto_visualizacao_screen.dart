import 'dart:io';

import 'package:flutter/material.dart';

/// Tela cheia com a foto de perfil, permitindo zoom com gesto de pinça.
class FotoVisualizacaoScreen extends StatelessWidget {
  const FotoVisualizacaoScreen({
    super.key,
    required this.arquivo,
    this.heroTag = 'foto-perfil',
  });

  final File arquivo;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Foto do Perfil'),
        centerTitle: true,
      ),
      body: Center(
        child: Hero(
          tag: heroTag,
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: Image.file(
              arquivo,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Não foi possível carregar a imagem.',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
