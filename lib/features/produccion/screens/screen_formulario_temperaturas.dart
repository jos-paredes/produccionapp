import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:http/http.dart' as http;
import 'package:produccionapp/core/constants/api_routes.dart';
import 'package:produccionapp/features/produccion/database/database_helper.dart';
import 'package:produccionapp/features/produccion/providers/registro_produccion_provider.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart' hide Image;

class FormularioTemperaturasScreen extends StatefulWidget {
  const FormularioTemperaturasScreen({super.key});

  @override
  State<FormularioTemperaturasScreen> createState() =>
      _FormularioTemperaturasScreenState();
}

class _FormularioTemperaturasScreenState
    extends State<FormularioTemperaturasScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> datosGuardados = {};
  final Map<String, SMIBool?> _inputs = {};
  final Map<String, String> _formData = {};
  final TransformationController _transformationController =
      TransformationController();
  final GlobalKey _imageKey = GlobalKey();
  Size? _imageSize;
  bool _enviandoDatos = false;

  @override
  void initState() {
    super.initState();
    _initializeInputs();
    _getImageSize();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _cargarDatosGuardados();
      _actualizarEstadoBotones();
    });
  }

  Future<void> _cargarDatosGuardados() async {
  final db = DatabaseHelper();
  final registro = await db.getUltimoRegistroActivo();
  
  // Limpiar datos actuales primero
  setState(() {
    datosGuardados.clear();
    _formData.clear();
  });
  
  if (registro != null) {
    final idRegistro = registro['idRegistro'];
    final res = await db.getTemperaturasActivasPorIdRegistro(idRegistro.toString());
    
    if (res != null && res['cerrado'] != 1) { // Solo cargar si no está cerrado
      final datosValidos = Map<String, dynamic>.from(res)
        ..removeWhere((key, value) => value == null);
      
      setState(() {
        datosGuardados = datosValidos;
        _formData.addAll(datosValidos.map((k, v) => MapEntry(k, v.toString())));
      });
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _formKey.currentState?.patchValue(datosValidos);
      });
    }
    
    _actualizarEstadoBotones();
  }
}

  void _actualizarEstadoBotones() {
  final todosLosCampos = [
    'enfriamiento_dato',
    'dato_1', 'dato_2', 'dato_3', 'dato_4', 'dato_5',
    'dato_6', 'dato_7', 'dato_8', 'dato_9', 'dato_10',
    'dato_11', 'dato_12', 'dato_13', 'dato_14', 'dato_15',
    'dato_16', 'dato_17', 'dato_18', 'dato_19',
    'tipo_cuello', 'peso_preforma',
    'espesor_1', 'espesor_2', 'espesor_3', 'espesor_4'
  ];

  // Si no hay datos guardados, limpiar todos los campos
  if (datosGuardados.isEmpty) {
    _formData.clear();
    if (_formKey.currentState != null) {
      _formKey.currentState?.reset();
    }
  } else {
    for (var campo in todosLosCampos) {
      if (datosGuardados.containsKey(campo)) {
        _formData[campo] = datosGuardados[campo].toString();
      }
    }
  }

  setState(() {});
}

void _limpiarAnimaciones() {
  _inputs.forEach((key, value) {
    if (value != null) {
      value.value = false;
    }
  });
}
  void _initializeInputs() {
    _inputs.addAll({
      'enfriamiento1': null,
      'temp_pt_1': null,
      'temp_pt_2': null,
      'temp_pt_3': null,
      'temp_pt_4': null,
      'temp_pt_5': null,
      'temp_pt_6': null,
      'temp_pt_7': null,
      'temp_pt_8': null,
      'tipo_cuello': null,
      'peso_preforma': null,
      'espesor_1': null,
      'espesor_2': null,
      'espesor_3': null,
      'espesor_4': null,
    });
  }

  void _getImageSize() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_imageKey.currentContext != null) {
        final RenderBox renderBox =
            _imageKey.currentContext!.findRenderObject() as RenderBox;
        setState(() {
          _imageSize = renderBox.size;
        });
      }
    });
  }

  void _mostrarDialogoCampoTexto(
    BuildContext context,
    String titulo,
    List<Map<String, String>> campos,
    String seccionKey,
  ) {
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          children: [
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: campos.map((campo) {
                final valorGuardado = datosGuardados[campo['name']]?.toString() ?? '';
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: campo['label']!,
                      hintText: campo['hint'] ?? '',
                      border: const OutlineInputBorder(),
                    ),
                    initialValue: _formData[campo['name']] ?? valorGuardado,
                    onSaved: (value) => _formData[campo['name']!] = value ?? '',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo requerido';
                      }
                      if (campo['name'] == 'tipo_cuello') {
                        return null;
                      }
                      if (double.tryParse(value.replaceAll(',', '.')) == null) {
                        return 'Ingrese un número válido';
                      }
                      return null;
                    },
                    keyboardType: campo['name'] == 'tipo_cuello' 
                        ? TextInputType.text 
                        : TextInputType.numberWithOptions(decimal: true),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                campos.forEach((campo) {
                  final valor = _formData[campo['name']];
                  _guardarCampo(seccionKey, campo['name']!, valor);
                });
                Navigator.pop(context);
                _toggleAnimation(seccionKey);
                _mostrarConfirmacion(context, 'Datos guardados para $titulo');
                _actualizarEstadoBotones();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _onRiveInit(Artboard artboard, String key) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      "State Machine 1",
    );
    if (controller != null) {
      artboard.addController(controller);
      final input = controller.findInput<bool>("Boolean 1");
      if (input is SMIBool) {
        setState(() => _inputs[key] = input..value = false);
      }
    }
  }

  void _toggleAnimation(String key) {
    if (_inputs[key] != null) {
      setState(() => _inputs[key]!.value = !_inputs[key]!.value);
    }
  }

  void _mostrarConfirmacion(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), duration: const Duration(seconds: 2)),
    );
  }

Future<void> _guardarCampo(String bt, String tipo, String? valor) async {
  if (valor == null || valor.isEmpty) return;
  
  final db = DatabaseHelper();
  final registro = await db.getUltimoRegistroActivo();
  
  if (registro != null) {
    final idRegistro = registro['idRegistro']; // Usar idRegistro en lugar de id
    print('Guardando campo $tipo con valor $valor para registro ID: $idRegistro');
    
    dynamic valorParaGuardar = tipo == 'tipo_cuello' 
        ? valor 
        : double.tryParse(valor.replaceAll(',', '.'))?.toString();
    
    await db.guardarCampoTemperaturaPorIdRegistro(
      idRegistro.toString(),
      tipo,
      valorParaGuardar ?? valor,
    );
    
    print('Campo guardado exitosamente');
    
    setState(() {
      datosGuardados[tipo] = valorParaGuardar ?? valor;
    });
  }
}

  Future<void> _cerrarFormulario() async {
    final db = DatabaseHelper();
    final registro = await db.getUltimoRegistroActivo();
    if (registro != null) {
      await db.cerrarTemperaturas(registro['id']);
    }
  }

  Future<Map<String, dynamic>> _enviarTemperaturasAlServidor(Map<String, dynamic> datos) async {
  if (_enviandoDatos) return {'success': false, 'error': 'Envío en progreso'};
  
  setState(() => _enviandoDatos = true);
  
  try {
    final registroProvider = Provider.of<RegistroProduccionProvider>(context, listen: false);
    final idRegistro = registroProvider.idRegistro;
    
    if (idRegistro == null) {
      return {
        'success': false,
        'error': 'No hay un registro activo en el provider',
      };
    }

    // 1. Preparar datos para enviar asegurando que id_registro sea string
    final datosParaEnviar = {
      'id_registro': idRegistro.toString(), // Convertir explícitamente a string
      ...datos,
      'fecha_envio': DateTime.now().toIso8601String(),
    };

    // 2. Limpieza de datos
    datosParaEnviar.remove('id'); // Eliminar campo id si existe
    datosParaEnviar.removeWhere((key, value) => value == null); // Eliminar nulos
    datosParaEnviar.remove('fecha_creacion'); // Eliminar campos internos
    datosParaEnviar.remove('fecha_actualizacion');
    datosParaEnviar.remove('cerrado');

    // 3. Conversión de tipos de datos
    final camposNumericos = [
      'enfriamiento_dato', 'dato_1', 'dato_2', 'dato_3', 'dato_4', 'dato_5',
      'dato_6', 'dato_7', 'dato_8', 'dato_9', 'dato_10', 'dato_11', 'dato_12',
      'dato_13', 'dato_14', 'dato_15', 'dato_16', 'dato_17', 'dato_18', 'dato_19',
      'peso_preforma', 'espesor_1', 'espesor_2', 'espesor_3', 'espesor_4'
    ];

    datosParaEnviar.forEach((key, value) {
      if (camposNumericos.contains(key) && value is String) {
        datosParaEnviar[key] = double.tryParse(value) ?? value;
      }
    });

    // 4. Mostrar datos finales que se enviarán
    print('════════ DATOS FINALES PARA ENVIAR ════════');
    print('URL: ${ApiRoutes.temperaturas}');
    print('Método: POST');
    print('Headers: {Content-Type: application/json, Accept: application/json}');
    print('Body:');
    print(jsonEncode(datosParaEnviar));
    print('══════════════════════════════════════════');

    // 5. Enviar la solicitud
    final response = await http.post(
      Uri.parse(ApiRoutes.temperaturas),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(datosParaEnviar),
    ).timeout(const Duration(seconds: 30));

    // 6. Mostrar respuesta completa del servidor
    print('════════ RESPUESTA DEL SERVIDOR ════════');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');
    print('════════════════════════════════════════');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        'success': true,
        'message': 'Datos enviados correctamente',
        'data': jsonDecode(response.body),
      };
    } else {
      // Procesar errores específicos
      String errorMessage = 'Error ${response.statusCode}';
      try {
        final errorBody = jsonDecode(response.body);
        errorMessage += ' - ${errorBody['message'] ?? errorBody['error'] ?? response.body}';
      } catch (e) {
        errorMessage += ' - ${response.body}';
      }
      
      return {
        'success': false,
        'error': errorMessage,
        'statusCode': response.statusCode,
        'responseBody': response.body,
      };
    }
  } catch (e) {
    print('════════ ERROR DURANTE EL ENVÍO ════════');
    print(e.toString());
    print('═══════════════════════════════════════');
    
    return {
      'success': false,
      'error': 'Error de conexión: ${e.toString()}',
    };
  } finally {
    setState(() => _enviandoDatos = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
       floatingActionButton: FloatingActionButton(
  onPressed: _enviandoDatos ? null : () async {
    final registroProvider = Provider.of<RegistroProduccionProvider>(context, listen: false);
    final idRegistro = registroProvider.idRegistro;
    
    if (idRegistro == null) {
      _mostrarConfirmacion(context, 'No hay registro activo');
      return;
    }
    
    final db = DatabaseHelper();
    final temperaturasData = await db.getTemperaturasActivasPorIdRegistro(idRegistro);
    
    final datosAEnviar = {
      'id_registro': idRegistro,
      ...(temperaturasData ?? datosGuardados),
      'fecha_envio': DateTime.now().toIso8601String(),
    };
    
    final loadingSnackbar = ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Enviando datos...'),
          ],
        ),
        duration: Duration(minutes: 1), // Duración larga para que no desaparezca
      ),
    );
    
    try {
      final resultado = await _enviarTemperaturasAlServidor(datosAEnviar);
      
      loadingSnackbar.close();
      
      if (resultado['success'] == true) {
        // 1. Marcar como enviado en la base de datos
        await db.marcarTemperaturasComoEnviadas(idRegistro);
        
        // 2. Limpiar los datos en memoria
        setState(() {
          datosGuardados.clear();
          _formData.clear();
          _limpiarAnimaciones();
          if (_formKey.currentState != null) {
            _formKey.currentState?.reset();
          }
        });
        
        // 3. Recargar la pantalla para mostrar campos vacíos
        await _cargarDatosGuardados();
        
        _mostrarConfirmacion(context, '✅ Datos enviados correctamente');
      } else {
        _mostrarConfirmacion(context, 'Error al enviar: ${resultado['error']}');
      }
    } catch (e) {
      loadingSnackbar.close();
      _mostrarConfirmacion(context, 'Error inesperado: ${e.toString()}');
    }
  },
  tooltip: 'Enviar Temperaturas',
  backgroundColor: _enviandoDatos ? Colors.grey : Colors.green,
  child: _enviandoDatos
      ? const CircularProgressIndicator(color: Colors.white)
      : const Icon(Icons.send),
),

      body: LayoutBuilder(
        builder: (context, constraints) {
          return InteractiveViewer(
            transformationController: _transformationController,
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 2.5,
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/temp.png',
                    key: _imageKey,
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    fit: BoxFit.contain,
                  ),

                  if (_imageSize != null) ...[
                    Positioned(
                      left: 5,
                      top: 250,
                      child: _buildInteractiveButton(
                        context,
                        key: 'enfriamiento',
                        title: 'ENFRIAMIENTO',
                        fields: [
                          {
                            'name': 'enfriamiento_dato',
                            'label': 'enfriamiento',
                            'hint': '',
                          },
                        ],
                      ),
                    ),

                    // Sección 1
                    Positioned(
                      left: 55,
                      top: 250,
                      child: _buildInteractiveButton(
                        context,
                        key: 'temp_pt_1',
                        title: 'SECCION 1',
                        fields: [
                          {'name': 'dato_1', 'label': '(s)', 'hint': ''},
                          {'name': 'dato_2', 'label': '(bar)', 'hint': ''},
                          {'name': 'dato_3', 'label': '(bar)', 'hint': ''},
                        ],
                      ),
                    ),

                    // Sección 2
                    Positioned(
                      left: 92,
                      top: 250,
                      child: _buildInteractiveButton(
                        context,
                        key: 'temp_pt_2',
                        title: 'SECCION 2',
                        fields: [
                          {'name': 'dato_4', 'label': '(s)', 'hint': ''},
                          {'name': 'dato_5', 'label': '(bar)', 'hint': ''},
                          {'name': 'dato_6', 'label': '(bar)', 'hint': ''},
                        ],
                      ),
                    ),

                    // Sección 3
                    Positioned(
                      left: 130,
                      top: 250,
                      child: _buildInteractiveButton(
                        context,
                        key: 'temp_pt_3',
                        title: 'SECCION 3',
                        fields: [
                          {'name': 'dato_7', 'label': '(s)', 'hint': ''},
                          {'name': 'dato_8', 'label': '(bar)', 'hint': ''},
                          {'name': 'dato_9', 'label': '(bar)', 'hint': ''},
                        ],
                      ),
                    ),

                    // Sección 4
                    Positioned(
                      left: 170,
                      top: 240,
                      child: _buildInteractiveButton(
                        context,
                        key: 'temp_pt_4',
                        title: 'SECCION 4',
                        fields: [
                          {
                            'name': 'dato_10',
                            'label': 'Valor (g/s)',
                            'hint': '',
                          },
                          {
                            'name': 'dato_11',
                            'label': 'Valor (g/s)',
                            'hint': '',
                          },
                        ],
                      ),
                    ),

                    // Sección 5
                    Positioned(
                      left: 208,
                      top: 240,
                      child: _buildInteractiveButton(
                        context,
                        key: 'temp_pt_5',
                        title: 'SECCION 5',
                        fields: [
                          {
                            'name': 'dato_12',
                            'label': 'Valor (g/s)',
                            'hint': '',
                          },
                          {
                            'name': 'dato_13',
                            'label': 'Valor (g/s)',
                            'hint': '',
                          },
                        ],
                      ),
                    ),

                    // Sección 6
                    Positioned(
                      left: 245,
                      top: 240,
                      child: _buildInteractiveButton(
                        context,
                        key: 'temp_pt_6',
                        title: 'SECCION 6',
                        fields: [
                          {
                            'name': 'dato_14',
                            'label': 'Valor (g/s)',
                            'hint': '',
                          },
                          {
                            'name': 'dato_15',
                            'label': 'Valor (g/s)',
                            'hint': '',
                          },
                        ],
                      ),
                    ),

                    // Sección 7
                    Positioned(
                      left: 285,
                      top: 240,
                      child: _buildInteractiveButton(
                        context,
                        key: 'temp_pt_7',
                        title: 'SECCION 7',
                        fields: [
                          {
                            'name': 'dato_16',
                            'label': 'Valor (g/s)',
                            'hint': '',
                          },
                          {
                            'name': 'dato_17',
                            'label': 'Valor (g/s)',
                            'hint': '',
                          },
                        ],
                      ),
                    ),

                    // Sección 8
                    Positioned(
                      left: 318,
                      top: 240,
                      child: _buildInteractiveButton(
                        context,
                        key: 'temp_pt_8',
                        title: 'SECCION 8',
                        fields: [
                          {
                            'name': 'dato_18',
                            'label': 'Valor (g/s)',
                            'hint': '',
                          },
                          {
                            'name': 'dato_19',
                            'label': 'Valor (g/s)',
                            'hint': '',
                          },
                        ],
                      ),
                    ),

                    // Sección tipo cuello
                    Positioned(
                      left: 38,
                      top: 330,
                      child: _buildInteractiveButton(
                        context,
                        key: 'tipo_cuello',
                        title: 'SECCION TIPO CUELLO',
                        fields: [
                          {'name': 'tipo_cuello', 'label': 'Valor', 'hint': ''},
                        ],
                      ),
                    ),

                    // Sección PESO PREFORMA
                    Positioned(
                      left: 120,
                      top: 330,
                      child: _buildInteractiveButton(
                        context,
                        key: 'peso_preforma',
                        title: 'PESO PREFORMA',
                        fields: [
                          {
                            'name': 'peso_preforma',
                            'label': 'Peso (g)',
                            'hint': '',
                          },
                        ],
                      ),
                    ),

                    // Sección ESPESOR 1
                    Positioned(
                      left: 185,
                      top: 320,
                      child: _buildInteractiveButton(
                        context,
                        key: 'espesor_1',
                        title: 'ESPESOR',
                        fields: [
                          {'name': 'espesor_1', 'label': '(mm)', 'hint': ''},
                        ],
                      ),
                    ),

                    // Sección ESPESOR 2
                    Positioned(
                      left: 237,
                      top: 330,
                      child: _buildInteractiveButton(
                        context,
                        key: 'espesor_2',
                        title: 'ESPESOR',
                        fields: [
                          {'name': 'espesor_2', 'label': '(mm)', 'hint': ''},
                        ],
                      ),
                    ),

                    // Sección ESPESOR 3
                    Positioned(
                      left: 256,
                      top: 310,
                      child: _buildInteractiveButton(
                        context,
                        key: 'espesor_3',
                        title: 'ESPESOR',
                        fields: [
                          {'name': 'espesor_3', 'label': '(mm)', 'hint': ''},
                        ],
                      ),
                    ),

                    // Sección ESPESOR 4
                    Positioned(
                      left: 307,
                      top: 310,
                      child: _buildInteractiveButton(
                        context,
                        key: 'espesor_4',
                        title: 'ESPESOR',
                        fields: [
                          {'name': 'espesor_4', 'label': '(mm)', 'hint': ''},
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
 Widget _buildInteractiveButton(
    BuildContext context, {
    required String key,
    required String title,
    required List<Map<String, String>> fields,
  }) {
    bool todosCompletos = fields.every((field) => datosGuardados[field['name']] != null);

    return SizedBox(
      width: 60,
      height: 60,
      child: GestureDetector(
        onTap: () => _mostrarDialogoCampoTexto(context, title, fields, key),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: todosCompletos
                    ? Colors.green.withOpacity(0.7)
                    : Colors.red.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: Text(
                fields.length.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: RiveAnimation.asset(
                "assets/images/rive/botonazooo.riv",
                onInit: (artboard) => _onRiveInit(artboard, key),
              ),
            ),
          ],
        ),
      ),
    );
  }
}