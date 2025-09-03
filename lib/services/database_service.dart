import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/timer_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'timers.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE timers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        steps TEXT
      )
    ''');
  }

  Future<int> insertTimer(TimerConfiguration timer) async {
    final db = await database;
    final jsonSteps = jsonEncode(
      timer.steps.map((step) => step.toJson()).toList(),
    );
    return await db.insert('timers', {'name': timer.name, 'steps': jsonSteps});
  }

  Future<int> updateTimer(TimerConfiguration timer) async {
    final db = await database;
    final jsonSteps = jsonEncode(
      timer.steps.map((step) => step.toJson()).toList(),
    );
    return await db.update(
      'timers',
      {'name': timer.name, 'steps': jsonSteps},
      where: 'id = ?',
      whereArgs: [timer.id],
    );
  }

  Future<List<TimerConfiguration>> getTimers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('timers');

    return List.generate(maps.length, (i) {
      final stepsList = jsonDecode(maps[i]['steps'] as String) as List;
      final steps = stepsList
          .map(
            (stepJson) => TimerStep.fromJson(stepJson as Map<String, dynamic>),
          )
          .toList();
      return TimerConfiguration(
        id: maps[i]['id'],
        name: maps[i]['name'],
        steps: steps,
      );
    });
  }

  Future<void> deleteTimer(int id) async {
    final db = await database;
    await db.delete('timers', where: 'id = ?', whereArgs: [id]);
  }
}
