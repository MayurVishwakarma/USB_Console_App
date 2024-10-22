import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:usb_console_application/models/NodeDetailsModel.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  DatabaseHelper.internal();

  Future<Database> initDb() async {
    // Get the path for the database
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'usbconsoleapp.db');

    // Log the database path to the console
    print('Database path: $path');

    // Open and create the database if it doesn't exist
    return await openDatabase(
      path,
      version: 2,
      onCreate: (Database db, int version) async {
        print('Database created!'); // Log database creation
        // Optionally, you can create a general table here if needed
      },
    );
  }

  Future<void> createProjectTable(String projectName) async {
    var dbClient = await db;

    // Table name based on project name
    String tableName = '${projectName.toLowerCase()}_NodeList';

    // Check if the table already exists
    var result = await dbClient.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'");

    if (result.isEmpty) {
      // Create the 'node_details' table for the specific project
      await dbClient.execute('''
        CREATE TABLE $tableName (
          OmsId INTEGER,
          ChakNo TEXT UNIQUE,
          AmsId INTEGER,
          AmsNo TEXT,
          RmsId INTEGER,
          RmsNo TEXT,
          IsChecking INTEGER,
          GateWayId INTEGER,
          GatewayNo TEXT,
          GatewayName TEXT,
          Process1 TEXT,
          Process2 TEXT,
          Process3 TEXT,
          Process4 TEXT,
          Process5 TEXT,
          Process6 TEXT,
          AreaName TEXT,
          Description TEXT,
          Mechanical TEXT,
          Erection TEXT,
          DryCommissioning TEXT,
          WetCommissioning TEXT,
          Trenching TEXT,
          PipeInatallation TEXT,
          AutoDryCommissioning TEXT,
          AutoWetCommissioning TEXT,
          Chainage INTEGER,
          Coordinates TEXT,
          NetworkType TEXT,
          DeviceType TEXT,
          DeviceId INTEGER,
          DeviceNo TEXT,
          DeviceName TEXT,
          FirmwareVersion TEXT,
          SubChakQty INTEGER,
          MACAddress TEXT,
          Timestamp TEXT
        );
      ''');
      print('Table $tableName created!');
    } else {
      print('Table $tableName already exists.');
    }
  }

  Future<List<NodeDetailsModel>> getAllNodeDetails(String? projectName) async {
    var dbClient = await db;
    String tableName =
        '${projectName?.toLowerCase()}_NodeList'; // Use project-specific table
    List<Map<String, dynamic>> result = await dbClient.query(tableName);

    return result.map((data) => NodeDetailsModel.fromJson(data)).toList();
  }

  Future<void> insertNodeDetails(
      String projectName, NodeDetailsModel nodeDetails) async {
    var dbClient = await db;
    String tableName =
        '${projectName.toLowerCase()}_NodeList'; // Use project-specific table

    // Check if the record with the same chakNo already exists
    List<Map<String, dynamic>> existingRecords = await dbClient.query(
      tableName,
      where: 'ChakNo = ?',
      whereArgs: [nodeDetails.chakNo],
    );

    if (existingRecords.isEmpty) {
      await dbClient.insert(tableName, nodeDetails.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      print('Node detail inserted: ${nodeDetails.chakNo}');
    } else {
      print('Node detail with ChakNo ${nodeDetails.chakNo} already exists.');
    }
  }
}
