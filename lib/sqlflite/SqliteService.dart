import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/get_user_list.dart';

class DatabaseService {
  // Singleton pattern
  static final DatabaseService _databaseService = DatabaseService._internal();
  factory DatabaseService() => _databaseService;
  DatabaseService._internal();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    // Initialize the DB first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    final path = join(databasePath, 'zedor_database.db');

    return await openDatabase(
      path,
      onCreate: _onCreate,
      version: 1,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  // When the database is first created, create a table to store breeds
  // and a table to store dogs.
  Future<void> _onCreate(Database db, int version) async {
    // Run the CREATE {breeds} TABLE statement on the database.
    await db.execute(
      'CREATE TABLE getUserList(name TEXT, phone_number TEXT PRIMARY KEY, addStatus TEXT)',
    );
  }

  // Define a function that inserts breeds into the database
  Future<void> insertContact(GetUserListModel getUserListModel) async {
    final db = await _databaseService.database;
    await db.insert(
      'getUserList',
      getUserListModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<GetUserListModel>> getAllContactNames() async {
    final db = await _databaseService.database;
// you can use your initial name for dbClient
    List<Map> maps =
        await db.rawQuery('SELECT * FROM getUserList ORDER BY name;');

    //  List<Map> maps = await db.rawQuery("SELECT * FROM getUserList WHERE name LIKE '%sara%'");

    List<GetUserListModel> tableNameList = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        try {
          tableNameList.add(new GetUserListModel(
              phone_number: maps[i]['phone_number'].toString(),
              name: maps[i]['name'].toString(),
              addStatus: maps[i]['addStatus'].toString()));
        } catch (e) {
          print('Exeption : ' + e.toString());
        }
      }
    }
    return tableNameList;
  }

  Future<List<GetUserListModel>> getSearchContactByNames(
      String? keywords) async {
    final db = await _databaseService.database;
// you can use your initial name for dbClient
    String key = "'%" + keywords! + "%'";

    print("SELECT * FROM getUserList WHERE name LIKE ${key}");

    List<Map> maps =
        await db.rawQuery("SELECT * FROM getUserList WHERE name LIKE ${key}");
    //  List<Map> maps = await db.rawQuery("SELECT * FROM getUserList WHERE name LIKE '%sara%'");

    List<GetUserListModel> tableNameList = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        try {
          tableNameList.add(new GetUserListModel(
              phone_number: maps[i]['phone_number'].toString(),
              name: maps[i]['name'].toString(),
              addStatus: maps[i]['addStatus'].toString()));
        } catch (e) {
          print('Exeption : ' + e.toString());
        }
      }
    }

    return tableNameList;
  }

  // A method that retrieves all the breeds from the breeds table.
  Future<List<GetUserListModel>> getUserListModel() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('getUserList');

    return List.generate(
        maps.length, (index) => GetUserListModel.fromMap(maps[index]));
  }

  Future<GetUserListModel?> getContactUser(String? phone_number) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('getUserList',
        where: 'phone_number = ?', whereArgs: [phone_number]);
    return GetUserListModel.fromMap(maps[0]);
  }

  Future<bool> checkValue(String? phone_number) async {
    final db = await _databaseService.database;
    List<Map<String, dynamic>> maps = await db.query('getUserList',
        where: 'phone_number = ?', whereArgs: [phone_number]);
    if (maps.length > 0) {
      return true;
    }
    return false;
  }

  // A method that updates a breed data from the breeds table.

  Future<void> updateContact(GetUserListModel contactModel) async {
    final db = await _databaseService.database;
    await db.update(
      'getUserList',
      contactModel.toMap(),
      where: 'phone_number = ?',
      whereArgs: [contactModel.phone_number],
    );
  }

  // A method that deletes a breed data from the breeds table.
  Future<bool> isDeleteContact(String? phone_number) async {
    try {
      final db = await _databaseService.database;
      await db.delete(
        'getUserList',
        where: 'phone_number = ?',
        whereArgs: [phone_number],
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
