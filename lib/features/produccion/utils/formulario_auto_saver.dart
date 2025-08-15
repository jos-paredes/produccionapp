import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:produccionapp/features/produccion/database/database_helper.dart';
import 'package:produccionapp/features/produccion/providers/registro_produccion_provider.dart';
import 'package:provider/provider.dart';

class FormularioAutoSaver {
  final GlobalKey<FormBuilderState> formKey;
  final BuildContext context;
  final String tabla;

  FormularioAutoSaver({
    required this.formKey,
    required this.context,
    required this.tabla,
  });

  void onChangeListener() async {
    final idRegistro = Provider.of<RegistroProduccionProvider>(
      context,
      listen: false,
    ).idRegistro;

    if (idRegistro == null) return;

    final now = DateTime.now();
    final formData = formKey.currentState?.instantValue ?? {};

    final partialData = {
      ...formData,
      'id_registro': idRegistro,
      'cerrado': 0,
      'fecha_actualizacion': now.toIso8601String(),
    };

    switch (tabla) {
      case 'formulario_general':
        await DatabaseHelper().insertFormularioGeneral(partialData);
        break;
    // Puedes agregar más casos aquí si quieres reutilizar en otras tablas
    }

    debugPrint('📝 Guardado automático de "$tabla" a las ${now.toIso8601String()} ${partialData.toString()}');
  }
}
