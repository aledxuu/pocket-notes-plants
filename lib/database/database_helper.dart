import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/plant.dart';

class DatabaseHelper {
  // One reusable DatabaseHelper instance.
  static final DatabaseHelper instance = DatabaseHelper._internal();

  DatabaseHelper._internal();

  // One reusable database connection (cached as a Future, so the
  // database is opened exactly once even if two callers ask at once).
  static Future<Database>? _databaseFuture;

  Future<Database> get database => _databaseFuture ??= _initDatabase();

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'pocket_notes_plants.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE plants (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            plant_name TEXT NOT NULL,
            watering_notes TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // CREATE
  Future<int> insertPlant(Plant plant) async {
    final db = await database;
    return db.insert('plants', plant.toMap());
  }

  // READ
  Future<List<Plant>> getPlants() async {
    final db = await database;
    final maps = await db.query('plants', orderBy: 'id ASC');
    return maps.map(Plant.fromMap).toList();
  }

  // UPDATE: where + whereArgs
  Future<int> updatePlant(Plant plant) async {
    final db = await database;
    return db.update(
      'plants',
      plant.toMap(),
      where: 'id = ?',
      whereArgs: [plant.id],
    );
  }

  // DELETE: where + whereArgs
  Future<int> deletePlant(int id) async {
    final db = await database;
    return db.delete(
      'plants',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
