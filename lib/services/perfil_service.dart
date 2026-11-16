import 'package:shared_preferences/shared_preferences.dart';

/// Persiste os dados do perfil (nome e caminho da foto) no dispositivo.
class PerfilService {
  static const String nomePadrao = 'Diego Menegassi';

  static const String _chaveNome = 'perfil_nome';
  static const String _chaveCaminhoFoto = 'perfil_caminho_foto';

  Future<String> obterNome() async {
    final prefs = await SharedPreferences.getInstance();
    final nome = prefs.getString(_chaveNome);
    if (nome == null || nome.trim().isEmpty) return nomePadrao;
    return nome;
  }

  Future<void> salvarNome(String nome) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveNome, nome);
  }

  Future<String?> obterCaminhoFoto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chaveCaminhoFoto);
  }

  Future<void> salvarCaminhoFoto(String caminho) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveCaminhoFoto, caminho);
  }

  Future<void> removerCaminhoFoto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveCaminhoFoto);
  }
}
