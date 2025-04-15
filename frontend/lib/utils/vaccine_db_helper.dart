// Package imports:
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Project imports:
import '../models/vaccine.dart';

class VaccineDatabaseHelper {
  static VaccineDatabaseHelper? _vaccineDatabaseHelper; // singleton helper

  String vaccineTable = 'vaccine_table';
  String colId = 'id';
  String colName = 'name';
  String colProducer = 'producer';
  String colType = 'type';
  String colAmount = 'amount';
  String colHospital = 'hospital';
  String colRefrigeratorId = 'refrigerator_id';
  String colRefrigerator = 'refrigerator';
  String colOther = 'other';

  VaccineDatabaseHelper._createInstance();

  factory VaccineDatabaseHelper() {
    _vaccineDatabaseHelper ??= VaccineDatabaseHelper._createInstance();
    return _vaccineDatabaseHelper!;
  }

  static Database? _database; // singleton database
  Future<Database> get database async =>
    _database ??= await initializeDatabase();


  Future<Database> initializeDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'vaccines.db');
      var vaccineDatabase =
          await openDatabase(path, version: 1,
            onCreate: (db, version) async =>
            await db.execute("CREATE TABLE vaccines($colId INTEGER PRIMARY KEY, $colName TEXT, $colProducer TEXT, $colType TEXT, $colAmount INTEGER, $colHospital TEXT, $colRefrigeratorId INTEGER, $colRefrigerator TEXT, $colOther TEXT);"),
          );
      return vaccineDatabase;
    } catch(e) {
      throw Exception('Error initializing database: $e');
    } 
  }

  Future<int> insertVaccine(Vaccine vaccine) async {
    Database db = await database;
    return await db.insert("vaccines", vaccine.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateVaccine(Vaccine vaccine) async {
    Database db = await database;
    return await db.update("vaccines", vaccine.toJson(),
      where: '$colId = ?',
      whereArgs: [vaccine.id],
      conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> deleteVaccine(Vaccine vaccine) async {
    Database db = await database;
    return await db.delete("vaccines",
      where: '$colId = ?',
      whereArgs: [vaccine.id],);
  }

  Future<List<Vaccine>?> queryVaccinesByColumnValue(String columnName, dynamic columnValue) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('vaccines',
      where: '$columnName = ?',
      whereArgs: [columnValue],);
    return List.generate(maps.length, (index) => Vaccine.fromJson(maps[index]));
  }

  Future<List<Vaccine>?> getAllVaccines() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('vaccines');

    if (maps.isEmpty) return null;
    return List.generate(maps.length, (index) => Vaccine.fromJson(maps[index]));
  }

}
