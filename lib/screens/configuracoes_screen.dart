import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class ConfiguracoesScreen extends StatefulWidget {
  final Function(bool) onTemaAlterado;
  const ConfiguracoesScreen({super.key, required this.onTemaAlterado});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  final _service = PreferencesService();
  final _nomeController = TextEditingController();
  final _tarefaController = TextEditingController();

  bool _modoEscuro = false;
  bool _carregando = true;
  String _ultimoAcesso = '';
  List<Map<String, dynamic>> _historicoTarefas = [];

  @override
  void initState() {
    super.initState();
    _carregarPreferencias();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _tarefaController.dispose();
    super.dispose();
  }

  Future<void> _carregarPreferencias() async {
    final nome = await _service.obterNomeUsuario();
    final modoEscuro = await _service.obterModoEscuro();
    final ultimoAcesso = await _service.obterUltimoAcesso();
    final historico = await _service.obterHistorico();

    setState(() {
      _nomeController.text = nome;
      _modoEscuro = modoEscuro;
      _ultimoAcesso = ultimoAcesso;
      _historicoTarefas = historico;
      _carregando = false;
    });
  }

  Future<void> _salvarPreferencias() async {
    await _service.salvarNomeUsuario(_nomeController.text);
    await _service.salvarModoEscuro(_modoEscuro);
    await _service.salvarHistorico(_historicoTarefas);

    widget.onTemaAlterado(_modoEscuro);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferências salvas com sucesso!')),
      );
    }
  }

  // --- Desafio Intermediário: Resetar Preferências ---
  Future<void> _redefinirPadroes() async {
    await _service.limparTudo();
    await _service.registrarUltimoAcesso();
    final novoAcesso = await _service.obterUltimoAcesso();

    setState(() {
      _nomeController.text = 'Usuário Convidado';
      _modoEscuro = false;
      _historicoTarefas = [];
      _ultimoAcesso = novoAcesso;
    });

    widget.onTemaAlterado(false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configurações redefinidas para o padrão!')),
      );
    }
  }

  // --- Desafio Avançado: Manipulação da Lista JSON ---
  void _adicionarTarefa() {
    if (_tarefaController.text.trim().isEmpty) return;

    setState(() {
      _historicoTarefas.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'titulo': _tarefaController.text.trim(),
      });
      _tarefaController.clear();
    });
    _service.salvarHistorico(_historicoTarefas);
  }

  void _removerTarefa(int index) {
    setState(() {
      _historicoTarefas.removeAt(index);
    });
    _service.salvarHistorico(_historicoTarefas);
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações & Perfil'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do Usuário',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Ativar Modo Escuro'),
              subtitle: const Text('Persiste o tema visual selecionado no disco'),
              value: _modoEscuro,
              onChanged: (valor) => setState(() => _modoEscuro = valor),
            ),
            const Divider(),

            // --- Desafio Avançado UI ---
            const Text(
              'Histórico de Pesquisas / Tarefas (JSON):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tarefaController,
                    decoration: const InputDecoration(
                      hintText: 'Adicionar item...',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.add),
                  onPressed: _adicionarTarefa,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _historicoTarefas.isEmpty
                  ? const Center(child: Text('Nenhum item salvo no histórico JSON.'))
                  : ListView.builder(
                      itemCount: _historicoTarefas.length,
                      itemBuilder: (context, index) {
                        final item = _historicoTarefas[index];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.history),
                          title: Text(item['titulo'] ?? ''),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => _removerTarefa(index),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),

            // Botão de Salvar Alterações
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _salvarPreferencias,
                icon: const Icon(Icons.save),
                label: const Text('Salvar Alterações'),
              ),
            ),
            const SizedBox(height: 6),

            // --- Desafio Intermediário UI ---
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _redefinirPadroes,
                icon: const Icon(Icons.restore),
                label: const Text('Redefinir Padrões'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              ),
            ),
            const SizedBox(height: 12),

            // --- Desafio Básico UI: Rodapé ---
            Center(
              child: Text(
                'Último acesso: $_ultimoAcesso',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}