import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/tarefa_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  static const String _nomeBanco = 'tarefas_app.db';
  static const String _tabela = 'tarefas';

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_nomeBanco);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tabela (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descricao TEXT NOT NULL,
        concluida INTEGER NOT NULL DEFAULT 0,
        categoria TEXT NOT NULL DEFAULT 'Geral'
      )
    ''');
  }

  /// CREATE: insere uma nova tarefa e retorna o id gerado.
  Future<int> criarTarefa(TarefaModel tarefa) async {
    final db = await database;
    return db.insert(_tabela, tarefa.toMap());
  }

  /// READ: lista as tarefas, aplicando busca e/ou filtro por categoria.
  Future<List<TarefaModel>> listarTarefas({
    String? busca,
    String? categoria,
  }) async {
    final db = await database;

    final filtros = <String>[];
    final argumentos = <Object?>[];

    final termo = busca?.trim();
    if (termo != null && termo.isNotEmpty) {
      filtros.add('(titulo LIKE ? OR descricao LIKE ?)');
      argumentos.addAll(['%$termo%', '%$termo%']);
    }

    if (categoria != null && categoria.isNotEmpty) {
      filtros.add('categoria = ?');
      argumentos.add(categoria);
    }

    final result = await db.query(
      _tabela,
      where: filtros.isEmpty ? null : filtros.join(' AND '),
      whereArgs: argumentos.isEmpty ? null : argumentos,
      orderBy: 'id DESC',
    );

    return result.map((map) => TarefaModel.fromMap(map)).toList();
  }

  /// UPDATE: atualiza todos os campos da tarefa pelo id.
  Future<int> atualizarTarefa(TarefaModel tarefa) async {
    final db = await database;
    return db.update(
      _tabela,
      tarefa.toMap(),
      where: 'id = ?',
      whereArgs: [tarefa.id],
    );
  }

  /// DELETE: remove a tarefa pelo id.
  Future<int> deletarTarefa(int id) async {
    final db = await database;
    return db.delete(
      _tabela,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Contadores usados no AppBar (total e concluídas).
  Future<Map<String, int>> contarTarefas() async {
    final db = await database;
    final resultado = await db.rawQuery('''
      SELECT COUNT(*) AS total,
             SUM(CASE WHEN concluida = 1 THEN 1 ELSE 0 END) AS concluidas
      FROM $_tabela
    ''');

    final linha = resultado.first;
    return {
      'total': (linha['total'] as int?) ?? 0,
      'concluidas': (linha['concluidas'] as int?) ?? 0,
    };
  }

  Future<void> fecharBanco() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
