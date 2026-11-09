import 'dart:async';

import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/tarefa_model.dart';

class TarefasScreen extends StatefulWidget {
  const TarefasScreen({super.key});

  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen>
    with SingleTickerProviderStateMixin {
  final _dbHelper = DatabaseHelper.instance;
  final _buscaController = TextEditingController();

  late final TabController _tabController;
  Timer? _debounce;

  List<TarefaModel> _tarefas = [];
  bool _carregando = true;
  int _total = 0;
  int _concluidas = 0;
  String? _categoriaSelecionada;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: TarefaModel.categorias.length + 1,
      vsync: this,
    );
    _carregarTarefas();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _buscaController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  bool get _temFiltro =>
      _buscaController.text.trim().isNotEmpty || _categoriaSelecionada != null;

  Future<void> _carregarTarefas() async {
    setState(() => _carregando = true);

    try {
      final lista = await _dbHelper.listarTarefas(
        busca: _buscaController.text,
        categoria: _categoriaSelecionada,
      );
      final contadores = await _dbHelper.contarTarefas();

      if (!mounted) return;
      setState(() {
        _tarefas = lista;
        _total = contadores['total'] ?? 0;
        _concluidas = contadores['concluidas'] ?? 0;
        _carregando = false;
      });
    } catch (erro) {
      if (!mounted) return;
      setState(() => _carregando = false);
      _mostrarMensagem('Erro ao carregar tarefas: $erro');
    }
  }

  void _buscar(String _) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _carregarTarefas);
  }

  void _selecionarCategoria(int index) {
    setState(() {
      _categoriaSelecionada =
          index == 0 ? null : TarefaModel.categorias[index - 1];
    });
    _carregarTarefas();
  }

  void _limparBusca() {
    _buscaController.clear();
    setState(() {});
    _carregarTarefas();
  }

  void _limparFiltros() {
    _buscaController.clear();
    _tabController.animateTo(0);
    setState(() => _categoriaSelecionada = null);
    _carregarTarefas();
  }

  Future<void> _abrirFormulario({TarefaModel? tarefa}) async {
    final salvou = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _TarefaFormSheet(tarefa: tarefa),
    );

    if (salvou == true) {
      await _carregarTarefas();
    }
  }

  Future<void> _alternarConclusao(TarefaModel tarefa, bool concluida) async {
    try {
      await _dbHelper.atualizarTarefa(
        tarefa.copyWith(concluida: concluida),
      );
      await _carregarTarefas();
    } catch (erro) {
      _mostrarMensagem('Erro ao atualizar tarefa: $erro');
    }
  }

  Future<void> _confirmarExclusao(TarefaModel tarefa) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir tarefa'),
        content: Text('Deseja excluir "${tarefa.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmou != true) return;

    try {
      await _dbHelper.deletarTarefa(tarefa.id!);
      await _carregarTarefas();
      _mostrarMensagem('Tarefa excluída.');
    } catch (erro) {
      _mostrarMensagem('Erro ao excluir tarefa: $erro');
    }
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas SQLite'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Tooltip(
                message: 'Tarefas concluídas / total',
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: cores.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: cores.onPrimaryContainer,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$_concluidas/$_total',
                        style: TextStyle(
                          color: cores.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          onTap: _selecionarCategoria,
          tabs: [
            const Tab(text: 'Todas'),
            ...TarefaModel.categorias.map((categoria) => Tab(text: categoria)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Nova tarefa'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _buscaController,
              onChanged: _buscar,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Buscar por título ou descrição...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _buscaController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpar busca',
                        icon: const Icon(Icons.clear),
                        onPressed: _limparBusca,
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
            ),
          ),
          Expanded(child: _construirLista()),
        ],
      ),
    );
  }

  Widget _construirLista() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_tarefas.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              _temFiltro
                  ? 'Nenhuma tarefa encontrada.'
                  : 'Nenhuma tarefa cadastrada.',
            ),
            if (_temFiltro)
              TextButton(
                onPressed: _limparFiltros,
                child: const Text('Limpar filtros'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarTarefas,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
        itemCount: _tarefas.length,
        itemBuilder: (context, index) {
          final tarefa = _tarefas[index];

          return Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: Checkbox(
                value: tarefa.concluida,
                onChanged: (valor) =>
                    _alternarConclusao(tarefa, valor ?? false),
              ),
              title: Text(
                tarefa.titulo,
                style: TextStyle(
                  decoration:
                      tarefa.concluida ? TextDecoration.lineThrough : null,
                  color: tarefa.concluida
                      ? Theme.of(context).colorScheme.outline
                      : null,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tarefa.descricao.isNotEmpty) Text(tarefa.descricao),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.label_outline,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tarefa.categoria,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                tooltip: 'Excluir',
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _confirmarExclusao(tarefa),
              ),
              onTap: () => _abrirFormulario(tarefa: tarefa),
            ),
          );
        },
      ),
    );
  }
}

class _TarefaFormSheet extends StatefulWidget {
  final TarefaModel? tarefa;

  const _TarefaFormSheet({this.tarefa});

  @override
  State<_TarefaFormSheet> createState() => _TarefaFormSheetState();
}

class _TarefaFormSheetState extends State<_TarefaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloController;
  late final TextEditingController _descricaoController;
  late String _categoria;
  bool _salvando = false;

  bool get _editando => widget.tarefa != null;

  @override
  void initState() {
    super.initState();
    _tituloController =
        TextEditingController(text: widget.tarefa?.titulo ?? '');
    _descricaoController =
        TextEditingController(text: widget.tarefa?.descricao ?? '');
    _categoria = widget.tarefa?.categoria ?? TarefaModel.categorias.first;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    final tarefa = TarefaModel(
      id: widget.tarefa?.id,
      titulo: _tituloController.text.trim(),
      descricao: _descricaoController.text.trim(),
      concluida: widget.tarefa?.concluida ?? false,
      categoria: _categoria,
    );

    try {
      if (_editando) {
        await DatabaseHelper.instance.atualizarTarefa(tarefa);
      } else {
        await DatabaseHelper.instance.criarTarefa(tarefa);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (erro) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar tarefa: $erro')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _editando ? 'Editar Tarefa' : 'Nova Tarefa',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tituloController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) => (valor == null || valor.trim().isEmpty)
                    ? 'Informe um título'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descricaoController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) => (valor == null || valor.trim().isEmpty)
                    ? 'Informe uma descrição'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _categoria,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
                items: TarefaModel.categorias
                    .map(
                      (categoria) => DropdownMenuItem(
                        value: categoria,
                        child: Text(categoria),
                      ),
                    )
                    .toList(),
                onChanged: (valor) {
                  if (valor != null) {
                    setState(() => _categoria = valor);
                  }
                },
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _salvando ? null : _salvar,
                icon: _salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_editando ? 'Atualizar' : 'Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
