import 'dart:io';

import 'package:image_picker/image_picker.dart';

class MediaService {
  MediaService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const int _qualidadeImagem = 85;
  static const double _larguraMaxima = 1080;

  /// Captura uma foto usando a câmera nativa do dispositivo.
  Future<File?> tirarFoto() => _selecionarImagem(ImageSource.camera);

  /// Abre a galeria e retorna a imagem escolhida pelo usuário.
  Future<File?> selecionarDaGaleria() => _selecionarImagem(ImageSource.gallery);

  Future<File?> _selecionarImagem(ImageSource origem) async {
    final XFile? imagem = await _picker.pickImage(
      source: origem,
      imageQuality: _qualidadeImagem,
      maxWidth: _larguraMaxima,
    );

    if (imagem == null) return null;
    return File(imagem.path);
  }
}
