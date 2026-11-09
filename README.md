# Aula 13 — Persistência de Dados com SQLite (sqflite)

Aplicativo Flutter de gerenciamento de tarefas com CRUD completo em SQLite,
desenvolvido a partir do roteiro da Aula 13.

## Funcionalidades

- **Create**: cadastro de tarefas em um modal (`BottomSheet`).
- **Read**: listagem reativa com `ListView.builder` e `RefreshIndicator`.
- **Update**: edição da tarefa e marcação de concluída pelo `Checkbox`.
- **Delete**: exclusão com confirmação.
- **Contador no AppBar**: tarefas concluídas / total.
- **Busca SQL**: filtro por título ou descrição usando `LIKE`.
- **Filtro por categoria**: abas para Todas, Geral, Trabalho, Pessoal e Estudos.

## Estrutura

```text
lib/
├── database/
│   └── database_helper.dart   # Singleton, conexão e operações CRUD
├── models/
│   └── tarefa_model.dart      # Modelo com toMap() e fromMap()
├── screens/
│   └── tarefas_screen.dart    # Interface reativa e formulário
└── main.dart                  # Configuração do MaterialApp
```

## Banco de dados

Arquivo: `tarefas_app.db`

```sql
CREATE TABLE tarefas (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  titulo TEXT NOT NULL,
  descricao TEXT NOT NULL,
  concluida INTEGER NOT NULL DEFAULT 0,
  categoria TEXT NOT NULL DEFAULT 'Geral'
);
```

## Como executar

```bash
flutter pub get
flutter run
```

> O `sqflite` funciona em Android, iOS e macOS. Para executar em Windows ou
> Linux é necessário adicionar o pacote `sqflite_common_ffi` e configurar o
> `databaseFactory`.

## Testes

```bash
flutter test
flutter analyze
```

Os testes cobrem a serialização do `TarefaModel` (`toMap` / `fromMap`).

## Versionamento sugerido

```bash
git init
git add lib/models/ lib/database/ pubspec.yaml
git commit -m "feat: implementa modelo TarefaModel e camada DatabaseHelper com SQLite"
git add lib/screens/ lib/main.dart test/ README.md
git commit -m "feat: constroi interface reativa de tarefas com CRUD completo no SQLite"
git branch -M main
git remote add origin URL_DO_SEU_REPOSITORIO
git push -u origin main
```
