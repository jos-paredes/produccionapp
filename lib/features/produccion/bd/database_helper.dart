// features/produccion/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'produccion_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE registros(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idRegistro TEXT NOT NULL,
        nombreUsuario TEXT NOT NULL,
        turno TEXT NOT NULL,
        fecha TEXT NOT NULL,
        cerrado INTEGER DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE formulario_general (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_registro INTEGER,
        tonalidad TEXT,
        dosificacion_eco TEXT,
        gramaje TEXT,
        punto_ajuste TEXT,
        temp_proceso TEXT,
        dewpoint TEXT,
        temp_cono TEXT,
        presion_entrada_agua_molde TEXT,
        presion_salida_agua_molde TEXT,
        presion_entrada_agua_maquina TEXT,
        presion_salida_agua_maquina TEXT,
        punto_ajuste_chiller_2 TEXT,
        lectura_chiller_2 TEXT,
        temp_motor_m2 TEXT,
        temp_aire_torre_entrada TEXT,
        velocidad_tornillo TEXT,
        temp_aire_torre_salida TEXT,
        temp_cilindro TEXT,
        torre_cama1d TEXT,
        caudal_aire TEXT,
        temp_intercambiados TEXT,
        fecha_creacion TEXT,
        fecha_actualizacion TEXT,
        cerrado INTEGER DEFAULT 0
      );
    ''');
  }

  Future<int> insertRegistro(Map<String, dynamic> registro) async {
    final db = await database;
    return await db.insert('registros', registro);
  }

  Future<int> cerrarRegistro(String idRegistro) async {
    final db = await database;
    return await db.update(
      'registros',
      {'cerrado': 1},
      where: 'idRegistro = ?',
      whereArgs: [idRegistro],
    );
  }

  Future<List<Map<String, dynamic>>> getRegistros() async {
    final db = await database;
    return await db.query('registros');
  }

  Future<Map<String, dynamic>?> getUltimoRegistroActivo() async {
    final db = await database;
    final results = await db.query(
      'registros',
      where: 'cerrado = ?',
      whereArgs: [0],
      orderBy: 'id DESC',
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> insertFormularioGeneral(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      'formulario_general',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getFormularioGeneralByIdRegistro(int idRegistro) async {
    final db = await database;
    final results = await db.query(
      'formulario_general',
      where: 'id_registro = ? AND cerrado = 0',
      whereArgs: [idRegistro],
      orderBy: 'fecha_actualizacion DESC',
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }
}
