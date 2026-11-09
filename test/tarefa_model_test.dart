import 'package:app_aula12/models/tarefa_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TarefaModel', () {
    test('toMap converte o booleano para inteiro e inclui a categoria', () {
      final tarefa = TarefaModel(
        id: 1,
        titulo: 'Estudar SQLite',
        descricao: 'Revisar os métodos do sqflite',
        concluida: true,
        categoria: 'Estudos',
      );

      final map = tarefa.toMap();

      expect(map['id'], 1);
      expect(map['titulo'], 'Estudar SQLite');
      expect(map['descricao'], 'Revisar os métodos do sqflite');
      expect(map['concluida'], 1);
      expect(map['categoria'], 'Estudos');
    });

    test('fromMap reconstrói o objeto a partir de uma linha do banco', () {
      final tarefa = TarefaModel.fromMap({
        'id': 7,
        'titulo': 'Comprar café',
        'descricao': 'Passar no mercado',
        'concluida': 0,
        'categoria': 'Pessoal',
      });

      expect(tarefa.id, 7);
      expect(tarefa.titulo, 'Comprar café');
      expect(tarefa.descricao, 'Passar no mercado');
      expect(tarefa.concluida, isFalse);
      expect(tarefa.categoria, 'Pessoal');
    });

    test('fromMap usa a categoria Geral quando a coluna não existe', () {
      final tarefa = TarefaModel.fromMap({
        'id': 2,
        'titulo': 'Tarefa antiga',
        'descricao': 'Registro sem categoria',
        'concluida': 1,
      });

      expect(tarefa.categoria, 'Geral');
      expect(tarefa.concluida, isTrue);
    });

    test('copyWith altera somente os campos informados', () {
      final tarefa = TarefaModel(
        id: 3,
        titulo: 'Título original',
        descricao: 'Descrição original',
        categoria: 'Trabalho',
      );

      final atualizada = tarefa.copyWith(concluida: true);

      expect(atualizada.id, 3);
      expect(atualizada.titulo, 'Título original');
      expect(atualizada.descricao, 'Descrição original');
      expect(atualizada.categoria, 'Trabalho');
      expect(atualizada.concluida, isTrue);
    });
  });
}
