import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class ListoferyarDatabase {
  ListoferyarDatabase._();
  static final instance = ListoferyarDatabase._();
  Database? _database;

  static const databaseName = 'listoferyar.db';
  static const version = 1;

  Future<Database> get database async => _database ??= await _open();

  Future<Database> _open() async {
    final root = await getDatabasesPath();
    return openDatabase(
      p.join(root, databaseName),
      version: version,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE projects (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            employer TEXT NOT NULL DEFAULT '',
            consultant TEXT NOT NULL DEFAULT '',
            contractor TEXT NOT NULL DEFAULT '',
            resident_supervisor TEXT NOT NULL DEFAULT '',
            contract_date TEXT NOT NULL DEFAULT '',
            contract_number TEXT NOT NULL DEFAULT '',
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute('CREATE INDEX idx_projects_updated_at ON projects(updated_at DESC)');
        await db.execute('''
          CREATE TABLE project_nodes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            project_id INTEGER NOT NULL,
            parent_id INTEGER,
            name TEXT NOT NULL,
            sort_order INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY(project_id) REFERENCES projects(id) ON DELETE CASCADE,
            FOREIGN KEY(parent_id) REFERENCES project_nodes(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE INDEX idx_project_nodes_project_parent_sort
          ON project_nodes(project_id, parent_id, sort_order)
        ''');
      },
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db == null) return;
    await db.close();
    _database = null;
  }
}
