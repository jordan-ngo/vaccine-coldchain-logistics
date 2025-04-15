// // Package imports:
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
//
// // Project imports:
// import '../models/district.dart';
//
// class DistrictDatabaseHelper {
//   static DistrictDatabaseHelper? _districtDatabaseHelper; // singleton helper
//
//   String districtTable = 'district_table';
//   String colId = 'id';
//   String colName = 'name';
//   String colOther = 'other';
//
//   DistrictDatabaseHelper._createInstance() {
//     // You can initialize some default values or perform some initial setup here if needed
//     // For example:
//     print("Initializing District Database Helper");
//   }
//
//   factory DistrictDatabaseHelper() {
//     _districtDatabaseHelper ??= DistrictDatabaseHelper._createInstance();
//     return _districtDatabaseHelper!;
//   }
//
//   static Database? _database; // singleton database
//   Future<Database> get database async =>
//     _database ??= await initializeDatabase();
//
//
//   Future<Database> initializeDatabase() async {
//     try {
//       String path = join(await getDatabasesPath(), 'districts.db');
//       var districtDatabase =
//           await openDatabase(path, version: 1,
//             onCreate: (db, version) async =>
//             await db.execute("CREATE TABLE districts($colId INTEGER PRIMARY KEY, $colName TEXT, $colOther TEXT);"),
//           );
//       return districtDatabase;
//     } catch(e) {
//       throw Exception('Error initializing database: $e');
//     }
//   }
//
//   Future<int> insertDistrict(District district) async {
//     Database db = await database;
//     return await db.insert('districts', district.toJson(),
//       conflictAlgorithm: ConflictAlgorithm.replace);
//   }
//
//   Future<int> updateDistrict(District district) async {
//     Database db = await database;
//     return await db.update("districts", district.toJson(),
//       where: '$colId = ?',
//       whereArgs: [district.id],
//       conflictAlgorithm: ConflictAlgorithm.replace);
//   }
//
//   Future<int> deleteDistrict(District district) async {
//     Database db = await database;
//     return await db.delete("districts",
//       where: '$colId = ?',
//       whereArgs: [district.id],);
//   }
//
//   Future<List<District>?> getAllDistricts() async {
//     Database db = await database;
//     final List<Map<String, dynamic>> maps = await db.query('districts');
//
//     if (maps.isEmpty) return null;
//     return List.generate(maps.length, (index) => District.fromJson(maps[index]));
//   }
//
// }
