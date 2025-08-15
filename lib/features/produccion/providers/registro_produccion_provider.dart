// features/produccion/providers/registro_produccion_provider.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:produccionapp/features/produccion/database/database_helper.dart';

class RegistroProduccionProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  String? idRegistro;
  String? nombreUsuario;
  String? turno;
  DateTime? fecha;
  bool _registroActivo = false;

  Future<void> cargarRegistroActivo() async {
    final registro = await _dbHelper.getUltimoRegistroActivo();
    if (registro != null) {
      idRegistro = registro['idRegistro'] as String;
      nombreUsuario = registro['nombreUsuario'] as String;
      turno = registro['turno'] as String;
      fecha = DateTime.parse(registro['fecha'] as String);
      _registroActivo = true;
      notifyListeners();
    }
  }

  Future<void> crearRegistro({
    required String nombre,
    required String turno,
  }) async {
    if (!_registroActivo) {
      // Generar nuevo ID (auto-incremental manejado por SQL)
      final nuevoId = DateTime.now().millisecondsSinceEpoch.toString();

      final nuevoRegistro = {
        'idRegistro': nuevoId,
        'nombreUsuario': nombre,
        'turno': turno,
        'fecha': DateTime.now().toIso8601String(),
        'cerrado': 0,
      };

      await _dbHelper.insertRegistro(nuevoRegistro);

      // Actualizar estado local
      idRegistro = nuevoId;
      nombreUsuario = nombre;
      this.turno = turno;
      fecha = DateTime.now();
      _registroActivo = true;

      print('Registro guardado en SQLite: $nuevoRegistro');
      notifyListeners();
    }
  }

  Future<void> cerrarRegistro() async {
    if (_registroActivo && idRegistro != null) {
      await _dbHelper.cerrarRegistro(idRegistro!);
      _registroActivo = false;
      print('Registro cerrado en SQLite: $idRegistro');
      notifyListeners();
    }
  }

  bool get registroActivo => _registroActivo;

  // Cargar datos al iniciar el provider
  Future<void> initialize() async {
    await cargarRegistroActivo();
  }


}



