class TarefaModel {
  /// Categorias disponíveis para organizar as tarefas.
  static const List<String> categorias = [
    'Geral',
    'Trabalho',
    'Pessoal',
    'Estudos',
  ];

  final int? id;
  final String titulo;
  final String descricao;
  final bool concluida;
  final String categoria;

  TarefaModel({
    this.id,
    required this.titulo,
    required this.descricao,
    this.concluida = false,
    this.categoria = 'Geral',
  });

  /// Converte o objeto para o formato aceito pelo sqflite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'concluida': concluida ? 1 : 0,
      'categoria': categoria,
    };
  }

  /// Reconstrói o objeto a partir de uma linha do banco.
  factory TarefaModel.fromMap(Map<String, dynamic> map) {
    return TarefaModel(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String,
      concluida: (map['concluida'] as int) == 1,
      categoria: (map['categoria'] as String?) ?? 'Geral',
    );
  }

  TarefaModel copyWith({
    int? id,
    String? titulo,
    String? descricao,
    bool? concluida,
    String? categoria,
  }) {
    return TarefaModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      concluida: concluida ?? this.concluida,
      categoria: categoria ?? this.categoria,
    );
  }
}
