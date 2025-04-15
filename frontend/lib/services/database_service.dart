import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


Future<Database> getDatabase() async {
  var databasePath = join(await getDatabasesPath(), 'local_db.db');
  return openDatabase(databasePath);
}

Future<void> syncDataOnLogin(List<dynamic> districts) async {
  Database database = await getDatabase();

  // Drop existing tables if they exist
  await database.execute('DROP TABLE IF EXISTS refrigerators');
  await database.execute('DROP TABLE IF EXISTS hospitals');
  await database.execute('DROP TABLE IF EXISTS districts');
  await database.execute('DROP TABLE IF EXISTS logs'); // Drop logs table if it exists

  // Create new tables
  await database.execute('''
    CREATE TABLE districts(
      id INTEGER PRIMARY KEY,
      user_id INTEGER,
      name TEXT
    );
  ''');
  await database.execute('''
    CREATE TABLE hospitals(
      id INTEGER PRIMARY KEY,
      name TEXT,
      district_id INTEGER,
      FOREIGN KEY(district_id) REFERENCES districts(id)
    );
  ''');
  await database.execute('''
    CREATE TABLE refrigerators(
      id INTEGER PRIMARY KEY,
      name TEXT,
      model_id TEXT,
      manufacturer TEXT,
      temp_monitor_installed INTEGER,
      monitor_type TEXT,
      monitor_working INTEGER,
      voltage_regulator_installed INTEGER,
      regulator_type TEXT,
      vaccine_count INTEGER,
      hospital_id INTEGER,
      FOREIGN KEY(hospital_id) REFERENCES hospitals(id)
    );
  ''');

  // Create logs table
  await database.execute('''
    CREATE TABLE logs(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user INTEGER,
      district INTEGER,
      hospital INTEGER,
      refrigerator INTEGER,
      previous_value TEXT,
      new_value TEXT,
      timestamp TEXT
    );
  ''');

  // Populate the districts, hospitals, and refrigerators tables
  for (var district in districts) {
    await database.insert('districts', {
      'id': district['id'],
      'name': district['name'],
      'user_id': district['user_id']
    });

    for (var hospital in district['hospitals']) {
      await database.insert('hospitals', {
        'id': hospital['id'],
        'name': hospital['name'],
        'district_id': district['id'],
      });

      for (var refrigerator in hospital['refrigerators']) {
        await database.insert('refrigerators', {
          'id': refrigerator['id'],
          'name': refrigerator['name'],
          'model_id': refrigerator['model_id'],
          'manufacturer': refrigerator['manufacturer'],
          'temp_monitor_installed': refrigerator['temp_monitor_installed'] ? 1 : 0,
          'monitor_type': refrigerator['monitor_type'],
          'monitor_working': refrigerator['monitor_working'] ? 1 : 0,
          'voltage_regulator_installed': refrigerator['voltage_regulator_installed'] ? 1 : 0,
          'regulator_type': refrigerator['regulator_type'],
          'vaccine_count': refrigerator['vaccine_count'],
          'hospital_id': hospital['id'],
        });
      }
    }
  }
  
  print("everything is good!!");
}
