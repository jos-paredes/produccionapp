import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:http/http.dart' as http;
import 'package:produccionapp/core/constants/api_routes.dart';
import 'package:produccionapp/features/produccion/database/database_helper.dart';
import 'package:produccionapp/features/produccion/providers/registro_produccion_provider.dart';
import 'package:produccionapp/features/produccion/utils/formulario_auto_saver.dart';
import 'package:produccionapp/features/produccion/widgets/custom_dropdown.dart';
import 'package:produccionapp/features/produccion/widgets/custom_textfield.dart';
import 'package:produccionapp/features/produccion/widgets/linea_seccion.dart';
import 'package:provider/provider.dart';

class FormularioGeneralScreen extends StatefulWidget {
  const FormularioGeneralScreen({super.key});

  @override
  State<FormularioGeneralScreen> createState() =>
      _FormularioGeneralScreenState();
}

class _FormularioGeneralScreenState extends State<FormularioGeneralScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  Future<Map<String, dynamic>> _sendDataToServer(Map<String, dynamic> data) async {
  try {
    final response = await http.post(
      Uri.parse(ApiRoutes.formularioGeneral),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    debugPrint('Respuesta completa: ${response.body}'); // ¡Muestra la respuesta exacta!
    debugPrint('Bytes: ${response.bodyBytes}'); // Verifica bytes crudos

    if (response.body.isEmpty) {
      return {'success': false, 'message': 'Respuesta vacía del servidor'};
    }

    // Intenta decodificar mostrando más detalles del error
    try {
      final responseData = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'data': responseData,
      };
    } on FormatException catch (e) {
      debugPrint('Error al decodificar JSON: $e');
      debugPrint('Contenido problemático: ${response.body}');
      return {
        'success': false,
        'message': 'Formato JSON inválido. Verifica la respuesta del servidor.',
      };
    }

  } catch (e) {
    return {
      'success': false,
      'message': 'Error de conexión: ${e.toString()}',
    };
  }
}
  @override
  void initState() {
    super.initState();

    _autoSaver = FormularioAutoSaver(
      formKey: _formKey,
      context: context,
      tabla: 'formulario_general',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadLastIncompleteForm();
    });
  }

  Future<void> _loadLastIncompleteForm() async {
    final idRegistroStr = Provider.of<RegistroProduccionProvider>(
      context,
      listen: false,
    ).idRegistro;
    if (idRegistroStr == null) return;
    final idRegistro = int.tryParse(
      idRegistroStr.toString(),
    ); // Asegura que sea un int válido
    if (idRegistro == null) return;

    final formData = await DatabaseHelper().getFormularioGeneralByIdRegistro(
      idRegistro,
    );

    if (formData != null && formData['cerrado'] == 0 && mounted) {
      // Remover campos que no están en el formulario
      final cleanedData = Map<String, dynamic>.from(formData)
        ..remove('id')
        ..remove('id_registro')
        ..remove('fecha_creacion')
        ..remove('fecha_actualizacion')
        ..remove('cerrado');

      _formKey.currentState?.patchValue(cleanedData);
      debugPrint('📦 Formulario restaurado automáticamente con: $cleanedData');
    }
  }

  late FormularioAutoSaver _autoSaver;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: FormBuilder(
                key: _formKey,
                onChanged: () {
                  _autoSaver.onChangeListener();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomFormBuilderTextField(
                            name: 'tonalidad',
                            label: 'Tonalidad',
                            hintText: 'Ingresa la tonalidad',
                            validator: FormBuilderValidators.required(
                              errorText: 'Este campo es obligatorio',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomFormBuilderTextField(
                            name: 'dosificacion_eco',
                            label: 'Dosif. ECO',
                            hintText: 'Ingrese la dosificación',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomFormBuilderDropdown<String>(
                      name: 'gramaje',
                      label: 'Gramaje',
                      hintText: 'Seleccione el gramaje',
                      items: const ['Rojo', 'Verde', 'Azul'],
                    ),
                    const SizedBox(height: 16),
                    const DividerSection(title: 'Secador'),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              CustomFormBuilderTextField(
                                name: 'punto_ajuste',
                                label: 'Punto de Ajuste',
                                hintText: 'Ingrese el punto de ajuste',
                              ),
                              const SizedBox(height: 16),
                              CustomFormBuilderTextField(
                                name: 'temp_proceso',
                                label: 'Temp. de proceso',
                                hintText: 'Ingrese la temperatura de proceso',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            children: [
                              CustomFormBuilderTextField(
                                name: 'dewpoint',
                                label: 'Dewpoint',
                                hintText: 'Ingrese el Dewpoint',
                              ),
                              const SizedBox(height: 16),
                              CustomFormBuilderTextField(
                                name: 'temp_cono',
                                label: 'Temp. de cono',
                                hintText: 'Ingrese la temperatura de cono',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const DividerSection(title: 'Agua Molde'),
                    Row(
                      children: [
                        Expanded(
                          child: CustomFormBuilderTextField(
                            name: 'presion_entrada_agua_molde',
                            label: 'Presión Entrada',
                            hintText: 'Ingrese la presión',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomFormBuilderTextField(
                            name: 'presion_salida_agua_molde',
                            label: 'Presión Salida',
                            hintText: 'Ingrese la presión',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const DividerSection(title: 'Agua Máquina'),
                    Row(
                      children: [
                        Expanded(
                          child: CustomFormBuilderTextField(
                            name: 'presion_entrada_agua_maquina',
                            label: 'Presión Entrada',
                            hintText: 'Ingrese la presión',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomFormBuilderTextField(
                            name: 'presion_salida_agua_maquina',
                            label: 'Presión Salida',
                            hintText: 'Ingrese la presión',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const DividerSection(title: 'Chiller 2'),
                    Row(
                      children: [
                        Expanded(
                          child: CustomFormBuilderTextField(
                            name: 'punto_ajuste_chiller_2',
                            label: 'Punto de Ajuste',
                            hintText: 'Ingrese el punto',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomFormBuilderTextField(
                            name: 'lectura_chiller_2',
                            label: 'Lectura',
                            hintText: 'Ingrese la lectura',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              CustomFormBuilderTextField(
                                name: 'temp_motor_m2',
                                label: 'Temp. motor M2',
                                hintText: 'Ingrese la temperatura',
                              ),
                              const SizedBox(height: 16),
                              CustomFormBuilderTextField(
                                name: 'temp_aire_torre_entrada',
                                label: 'Temp. aire torre entrada',
                                hintText: 'Ingrese la temperatura',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            children: [
                              CustomFormBuilderTextField(
                                name: 'velocidad_tornillo',
                                label: 'Velocidad del Tornillo',
                                hintText: 'Ingrese la velocidad',
                              ),
                              const SizedBox(height: 16),
                              CustomFormBuilderTextField(
                                name: 'temp_aire_torre_salida',
                                label: 'Temp. aire torre salida',
                                hintText: 'Ingrese la temperatura',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomFormBuilderTextField(
                      name: 'temp_cilindro',
                      label: 'Temp. Cilindro',
                      hintText: 'Ingrese la temperatura',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomFormBuilderTextField(
                            name: 'torre_cama1d',
                            label: 'Torre Cama 1/D',
                            hintText: '',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomFormBuilderTextField(
                            name: 'caudal_aire',
                            label: 'Caudal de Aire',
                            hintText: '',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomFormBuilderTextField(
                      name: 'temp_intercambiados',
                      label: 'Temp. de Intercambiados',
                      hintText: '',
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                onPressed: () async {
  if (_formKey.currentState?.saveAndValidate() ?? false) {
    final formData = _formKey.currentState!.value;
    final now = DateTime.now();
    final registroProvider = Provider.of<RegistroProduccionProvider>(context, listen: false);
    final idRegistro = registroProvider.idRegistro;

    if (idRegistro == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay registro activo')),
      );
      return;
    }

    // Preparamos los datos para enviar
    final dataToSave = {
      ...formData,
      'id_registro': idRegistro,
      'cerrado': 1,
      'fecha_creacion': now.toIso8601String(),
      'fecha_actualizacion': now.toIso8601String(),
    };

    try {
      // Mostrar mensaje de inicio
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enviando datos...')),
      );

      // 1. Guardar localmente
      final localResult = await DatabaseHelper().insertFormularioGeneral(dataToSave);
      
      if (localResult > 0) {
        // 2. Intentar enviar al servidor
        final serverResponse = await _sendDataToServer(dataToSave);
        
        if (serverResponse['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(serverResponse['message'] ?? 'Datos enviados correctamente')),
          );
          
          // Opcional: Resetear el formulario después del éxito
          _formKey.currentState?.reset();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(serverResponse['message'] ?? 'Error al enviar al servidor')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar el registro localmente')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Completa los campos obligatorios')),
    );
  }
},                                                                                                                                                                                                          
                tooltip: 'Cerrar Formulario General',
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                child: const Icon(Icons.send),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
