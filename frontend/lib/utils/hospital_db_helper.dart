// // Package imports:
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
//
// // Project imports:
// import '../models/hospital.dart';
//
// class HospitalDatabaseHelper {
//
//   static HospitalDatabaseHelper? _hospitalDatabaseHelper; // singleton helper
//
//   String hospitalTable = 'hospital_table';
//   String colId = 'id';
//   String colName = 'name';
//   String colLocation = 'location';
//   String colDistrictId = 'district_id';
//   String colDistrict = 'district';
//   String colOther = 'other';
//
//   HospitalDatabaseHelper._createInstance();
//
//   factory HospitalDatabaseHelper() {
//     _hospitalDatabaseHelper ??= HospitalDatabaseHelper._createInstance();
//     return _hospitalDatabaseHelper!;
//   }
//
//   static Database? _database; // singleton database
//   Future<Database> get database async =>
//     _database ??= await initializeDatabase();
//
//
//   Future<Database> initializeDatabase() async {
//     try {
//       String path = join(await getDatabasesPath(), 'hospitals.db');
//       var hospitalDatabase =
//           await openDatabase(path, version: 1,
//             onCreate: (db, version) async =>
//             await db.execute("CREATE TABLE hospitals($colId INTEGER PRIMARY KEY, $colName TEXT, $colLocation TEXT, $colDistrictId INTEGER, $colDistrict TEXT, $colOther TEXT);"),
//           );
//       return hospitalDatabase;
//     } catch(e) {
//       throw Exception('Error initializing database: $e');
//     }
//   }
//
//   Future<int> insertHospital(Hospital hospital) async {
//     Database db = await database;
//     return await db.insert("hospitals", hospital.toJson(),
//       conflictAlgorithm: ConflictAlgorithm.replace);
//   }
//
//   Future<int> updateHospital(Hospital hospital) async {
//     Database db = await database;
//     return await db.update("hospitals", hospital.toJson(),
//       where: '$colId = ?',
//       whereArgs: [hospital.id],
//       conflictAlgorithm: ConflictAlgorithm.replace);
//   }
//
//   Future<int> deleteHospital(Hospital hospital) async {
//     Database db = await database;
//     return await db.delete("hospitals",
//       where: '$colId = ?',
//       whereArgs: [hospital.id],);
//   }
//
//   Future<List<Hospital>?> queryHospitalsByColumnValue(String columnName, dynamic columnValue) async {
//     Database db = await database;
//     final List<Map<String, dynamic>> maps = await db.query('hospitals',
//       where: '$columnName = ?',
//       whereArgs: [columnValue],);
//     return List.generate(maps.length, (index) => Hospital.fromJson(maps[index]));
//   }
//
//   Future<List<Hospital>?> getAllHospitals() async {
//     Database db = await database;
//     final List<Map<String, dynamic>> maps = await db.query('hospitals');
//
//     if (maps.isEmpty) return null;
//     return List.generate(maps.length, (index) => Hospital.fromJson(maps[index]));
//   }
//
// }
