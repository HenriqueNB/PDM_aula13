import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyNomeUsuario = 'key_nome_usuario';
  static const String _keyModoEscuro = 'key_modo_escuro';
  static const String _keyUltimoAcesso = 'key_ultimo_acesso';
  static const String _keyHistorico = 'key_historico_tarefas';

  // --- Nome do Usuário ---
  Future<void> salvarNomeUsuario(String nome) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNomeUsuario, nome);
  }

  Future<String> obterNomeUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNomeUsuario) ?? 'Usuário Convidado';
  }

  // --- Modo Escuro ---
  Future<void> salvarModoEscuro(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyModoEscuro, valor);
  }

  Future<bool> obterModoEscuro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyModoEscuro) ?? false;
  }

  // --- DESAFIO BÁSICO: Data do Último Acesso ---
  Future<void> registrarUltimoAcesso() async {
    final prefs = await SharedPreferences.getInstance();
    final agora = DateTime.now().toString().split('.')[0]; // Formata data/hora
    await prefs.setString(_keyUltimoAcesso, agora);
  }

  Future<String> obterUltimoAcesso() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUltimoAcesso) ?? 'Primeiro Acesso';
  }

  // --- DESAFIO AVANÇADO: Lista JSON em String ---
  Future<void> salvarHistorico(List<Map<String, dynamic>> tarefas) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(tarefas);
    await prefs.setString(_keyHistorico, jsonString);
  }

  Future<List<Map<String, dynamic>>> obterHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_keyHistorico);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    final List<dynamic> decodedList = jsonDecode(jsonString);
    return decodedList.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  // --- DESAFIO INTERMEDIÁRIO: Limpar Tudo ---
  Future<void> limparTudo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}