// features/produccion/database/database_helper.dart
import 'package:flutter/material.dart';
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
      version: 2, // ✅ Subimos versión para que se cree la nueva tabla
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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

    // ✅ Nueva tabla para resistencias
    await db.execute('''
      CREATE TABLE tb_resistencias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_registro INTEGER,
        bt1_max TEXT, bt1_min TEXT,
        bt2_max TEXT, bt2_min TEXT,
        bt3_max TEXT, bt3_min TEXT,
        bt4_max TEXT, bt4_min TEXT,
        bt5_max TEXT, bt5_min TEXT,
        bt9_max TEXT, bt9_min TEXT,
        bt11_max TEXT, bt11_min TEXT,
        bt12_max TEXT, bt12_min TEXT,
        bt13_max TEXT, bt13_min TEXT,
        bt14_max TEXT, bt14_min TEXT,
        bt15_max TEXT, bt15_min TEXT,
        bt16_max TEXT, bt16_min TEXT,
        bt17_max TEXT, bt17_min TEXT,
        bt19_max TEXT, bt19_min TEXT,
        fecha_creacion TEXT,
        fecha_actualizacion TEXT,
        cerrado INTEGER DEFAULT 0
      );
    ''');

    await db.execute('''
        CREATE TABLE tb_temperaturas (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          id_registro INTEGER,
          enfriamiento_dato REAL, 
          dato_1 REAL, dato_2 REAL, dato_3 REAL,
          dato_4 REAL, dato_5 REAL, dato_6 REAL,
          dato_7 REAL, dato_8 REAL, dato_9 REAL,
          dato_10 REAL, dato_11 REAL, dato_12 REAL,
          dato_13 REAL, dato_14 REAL, dato_15 REAL,
          dato_16 REAL, dato_17 REAL, dato_18 REAL,
          dato_19 REAL,
          tipo_cuello TEXT, 
          peso_preforma REAL,
          espesor_1 REAL, espesor_2 REAL, 
          espesor_3 REAL, espesor_4 REAL,
          fecha_creacion TEXT,
          fecha_actualizacion TEXT,
          cerrado INTEGER DEFAULT 0
        );
      ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // ✅ Si la tabla no existe, la creamos
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tb_resistencias (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          id_registro INTEGER,
          bt1_max TEXT, bt1_min TEXT,
          bt2_max TEXT, bt2_min TEXT,
          bt3_max TEXT, bt3_min TEXT,
          bt4_max TEXT, bt4_min TEXT,
          bt5_max TEXT, bt5_min TEXT,
          bt9_max TEXT, bt9_min TEXT,
          bt11_max TEXT, bt11_min TEXT,
          bt12_max TEXT, bt12_min TEXT,
          bt13_max TEXT, bt13_min TEXT,
          bt14_max TEXT, bt14_min TEXT,
          bt15_max TEXT, bt15_min TEXT,
          bt16_max TEXT, bt16_min TEXT,
          bt17_max TEXT, bt17_min TEXT,
          bt19_max TEXT, bt19_min TEXT,
          fecha_creacion TEXT,
          fecha_actualizacion TEXT,
          cerrado INTEGER DEFAULT 0
        );
      ''');

      if (oldVersion < 3) {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS tb_temperaturas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_registro INTEGER,
            enfriamiento_dato TEXT,
            temp_pt_1 TEXT,
            temp_pt_2 TEXT,
            temp_pt_3 TEXT,
            temp_pt_4 TEXT,
            temp_pt_5 TEXT,
            temp_pt_6 TEXT,
            temp_pt_7 TEXT,
            temp_pt_8 TEXT,
            tipo_cuello TEXT,
            peso_preforma TEXT,
            espesor_1 TEXT,
            espesor_2 TEXT,
            espesor_3 TEXT,
            espesor_4 TEXT,
            fecha_creacion TEXT,
            fecha_actualizacion TEXT,
            cerrado INTEGER DEFAULT 0
          );
        ''');
      }
    }
  }

  // =========================
  //  Métodos ya existentes
  // =========================
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

  Future<Map<String, dynamic>?> getFormularioGeneralByIdRegistro(
    int idRegistro,
  ) async {
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

  // =========================
//  Métodos para Resistencias (Versión mejorada)
// =========================

Future<int> crearRegistroResistencias(int idRegistro) async {
  final db = await database;
  
  // Verificar si ya existe un registro activo
  final existente = await db.query(
    'tb_resistencias',
    where: 'id_registro = ? AND cerrado = 0',
    whereArgs: [idRegistro],
  );

  if (existente.isNotEmpty) {
    return existente.first['id'] as int;
  }

  // Crear nuevo registro
  final nuevoId = await db.insert('tb_resistencias', {
    'id_registro': idRegistro,
    'fecha_creacion': DateTime.now().toIso8601String(),
    'fecha_actualizacion': DateTime.now().toIso8601String(),
    'cerrado': 0,
  });

  return nuevoId;
}

Future<Map<String, dynamic>?> getResistenciasActivas(int idRegistro) async {
  final db = await database;
  final results = await db.query(
    'tb_resistencias',
    where: 'id_registro = ? AND cerrado = 0',
    whereArgs: [idRegistro],
    limit: 1,
  );
  
  if (results.isEmpty) return null;
  
  // Crear un NUEVO mapa mutable a partir de los datos
  final Map<String, dynamic> result = Map<String, dynamic>.from(results.first);
  
  // Eliminar campos innecesarios (opcional)
  result.remove('id');
  result.remove('id_registro');
  result.remove('fecha_creacion');
  result.remove('fecha_actualizacion');
  result.remove('cerrado');
  
  return result;
}

Future<int> guardarCampoResistencia(int idRegistro, String campo, String valor) async {
  final db = await database;
  
  // Verificar si ya existe un registro
  final existente = await db.query(
    'tb_resistencias',
    where: 'id_registro = ? AND cerrado = 0',
    whereArgs: [idRegistro],
  );

  if (existente.isNotEmpty) {
    // Actualizar campo existente
    return await db.update(
      'tb_resistencias',
      {campo: valor, 'fecha_actualizacion': DateTime.now().toIso8601String()},
      where: 'id_registro = ? AND cerrado = 0',
      whereArgs: [idRegistro],
    );
  } else {
    // Crear nuevo registro
    final nuevoRegistro = {
      'id_registro': idRegistro,
      campo: valor,
      'fecha_creacion': DateTime.now().toIso8601String(),
      'fecha_actualizacion': DateTime.now().toIso8601String(),
      'cerrado': 0,
    };
    return await db.insert('tb_resistencias', nuevoRegistro);
  }
}

Future<int> cerrarResistencias(int idRegistro) async {
  final db = await database;
  
  // Debug: Verificar datos antes de cerrar
  final datosActuales = await db.query(
    'tb_resistencias',
    where: 'id_registro = ? AND cerrado = 0',
    whereArgs: [idRegistro],
  );
  debugPrint('📌 Datos antes de cerrar: ${datosActuales.toString()}');

  return await db.update(
    'tb_resistencias',
    {
      'cerrado': 1,
      'fecha_actualizacion': DateTime.now().toIso8601String(),
    },
    where: 'id_registro = ? AND cerrado = 0',
    whereArgs: [idRegistro],
  );
}
Future<int> actualizarResistencias({
  required int idRegistro,
  required Map<String, dynamic> valores,
}) async {
  final db = await database;
  
  // Asegurarse de que exista el registro
  await crearRegistroResistencias(idRegistro);
  
  // Preparar datos para actualizar
  final datosActualizacion = {
    ...valores,
    'fecha_actualizacion': DateTime.now().toIso8601String(),
  };

  return await db.update(
    'tb_resistencias',
    datosActualizacion,
    where: 'id_registro = ? AND cerrado = 0',
    whereArgs: [idRegistro],
  );
}

Future<Map<String, dynamic>?> getResistenciasPorIdRegistro(int idRegistro) async {
  final db = await database;
  final results = await db.query(
    'tb_resistencias',
    where: 'id_registro = ?',
    whereArgs: [idRegistro],
    orderBy: 'fecha_creacion DESC',
    limit: 1,
  );
  return results.isNotEmpty ? results.first : null;
}
  // =========================
  //  Métodos para Temperaturas
  // =========================

  Future<Map<String, dynamic>?> getTemperaturasActivas(int idRegistro) async {
    final db = await database;
    final results = await db.query(
      'tb_temperaturas',
      where: 'id_registro = ? AND cerrado = 0',
      whereArgs: [idRegistro],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> guardarCampoTemperatura(
  int idRegistro,
  String campo,
  dynamic valor,
) async {
  final db = await database;
  final existente = await getTemperaturasActivas(idRegistro);

  if (existente != null) {
    return await db.update(
      'tb_temperaturas',
      {
        campo: valor,
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      },
      where: 'id_registro = ? AND cerrado = 0',
      whereArgs: [idRegistro],
    );
  } else {
    return await db.insert('tb_temperaturas', {
      'id_registro': idRegistro,
      campo: valor,
      'cerrado': 0,
      'fecha_creacion': DateTime.now().toIso8601String(),
      'fecha_actualizacion': DateTime.now().toIso8601String(),
    });
  }
}

  // Método para cerrar temperaturas
Future<int> cerrarTemperaturas(int idRegistro) async {
  final db = await database;
  return await db.update(
    'tb_temperaturas',
    {
      'cerrado': 1,
      'fecha_actualizacion': DateTime.now().toIso8601String(),
    },
    where: 'id_registro = ? AND cerrado = 0',
    whereArgs: [idRegistro],
  );
}
Future<int> marcarTemperaturasComoEnviadas(String idRegistro) async {
  final db = await database;
  return await db.update(
    'tb_temperaturas',
    {
      'cerrado': 1,
      'fecha_actualizacion': DateTime.now().toIso8601String(),
    },
    where: 'id_registro = ? AND cerrado = 0',
    whereArgs: [idRegistro],
  );
}
  // Agregar estos métodos a tu DatabaseHelper

  Future<List<Map<String, dynamic>>> getTodosLosRegistrosCompletos() async {
  final db = await database;
  
  // Obtener TODOS los registros principales
  final registros = await db.query(
    'registros',
    orderBy: 'id DESC', // Ordenar por ID descendente
  );

  debugPrint('📌 Número de registros principales encontrados: ${registros.length}');

  final resultadosCompletos = <Map<String, dynamic>>[];
  
  for (final registro in registros) {
    final idRegistro = registro['id'];
    debugPrint('🔍 Procesando registro ID: $idRegistro');

    // Obtener formulario general
    final formularioGeneral = await db.query(
      'formulario_general',
      where: 'id_registro = ?',
      whereArgs: [idRegistro],
      orderBy: 'id DESC',
      limit: 1,
    );
    debugPrint('📋 Formulario general encontrados: ${formularioGeneral.length}');

    // Obtener resistencias
    final resistencias = await db.query(
      'tb_resistencias',
      where: 'id_registro = ?',
      whereArgs: [idRegistro],
      orderBy: 'id DESC',
      limit: 1,
    );
    debugPrint('⚡ Resistencias encontradas: ${resistencias.length}');

    // Obtener temperaturas
    final temperaturas = await db.query(
      'tb_temperaturas',
      where: 'id_registro = ?',
      whereArgs: [idRegistro],
      orderBy: 'id DESC',
      limit: 1,
    );
    debugPrint('🌡️ Temperaturas encontradas: ${temperaturas.length}');

    resultadosCompletos.add({
      'registro': registro,
      'formulario_general': formularioGeneral.isNotEmpty ? formularioGeneral.first : null,
      'resistencias': resistencias.isNotEmpty ? resistencias.first : null,
      'temperaturas': temperaturas.isNotEmpty ? temperaturas.first : null,
    });
  }
  
  debugPrint('✅ Total de registros completos preparados: ${resultadosCompletos.length}');
  return resultadosCompletos;
}

  // Método para cerrar completamente un registro con todas sus relaciones
  Future<int> cerrarRegistroCompleto(int idRegistro) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.update(
        'registros',
        {'cerrado': 1},
        where: 'id = ?',
        whereArgs: [idRegistro],
      );

      await txn.update(
        'formulario_general',
        {'cerrado': 1},
        where: 'id_registro = ?',
        whereArgs: [idRegistro],
      );

      await txn.update(
        'tb_resistencias',
        {'cerrado': 1},
        where: 'id_registro = ?',
        whereArgs: [idRegistro],
      );

      await txn.update(
        'tb_temperaturas',
        {'cerrado': 1},
        where: 'id_registro = ?',
        whereArgs: [idRegistro],
      );
    });

    return 1;
  }
  // En DatabaseHelper agregar estos métodos:

Future<Map<String, dynamic>?> getTemperaturasActivasPorIdRegistro(String idRegistro) async {
  final db = await database;
  final results = await db.query(
    'tb_temperaturas',
    where: 'id_registro = ? AND cerrado = 0',
    whereArgs: [idRegistro],
    limit: 1,
  );
  return results.isNotEmpty ? results.first : null;
}

Future<int> guardarCampoTemperaturaPorIdRegistro(
  String idRegistro,
  String campo,
  dynamic valor,
) async {
  final db = await database;
  final existente = await getTemperaturasActivasPorIdRegistro(idRegistro);

  if (existente != null) {
    return await db.update(
      'tb_temperaturas',
      {
        campo: valor,
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      },
      where: 'id_registro = ? AND cerrado = 0',
      whereArgs: [idRegistro],
    );
  } else {
    return await db.insert('tb_temperaturas', {
      'id_registro': idRegistro,
      campo: valor,
      'cerrado': 0,
      'fecha_creacion': DateTime.now().toIso8601String(),
      'fecha_actualizacion': DateTime.now().toIso8601String(),
    });
  }
}
}
