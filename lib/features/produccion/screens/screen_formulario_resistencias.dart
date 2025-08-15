import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:produccionapp/core/constants/api_routes.dart';
import 'package:produccionapp/features/produccion/widgets/linea_seccion.dart';
import 'package:produccionapp/features/produccion/database/database_helper.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:produccionapp/features/produccion/providers/registro_produccion_provider.dart';

class FormularioResistenciasScreen extends StatefulWidget {
  const FormularioResistenciasScreen({super.key});

  @override
  State<FormularioResistenciasScreen> createState() =>
      _FormularioResistenciasScreenState();
}

class _FormularioResistenciasScreenState
    extends State<FormularioResistenciasScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> datosGuardados = {};
  final List<String> btTargets = [
    'BT1', 'BT2', 'BT3', 'BT4', 'BT5', 'BT9',
    'BT11', 'BT12', 'BT13', 'BT14', 'BT15', 'BT16', 'BT17', 'BT19'
  ];
  bool _isSubmitting = false;
  late RegistroProduccionProvider _registroProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _registroProvider = Provider.of<RegistroProduccionProvider>(context);
    _cargarDatosGuardados();
  }

  Future<void> _cargarDatosGuardados() async {
  if (_registroProvider.idRegistro == null) return;

  final db = DatabaseHelper();
  final idRegistro = int.tryParse(_registroProvider.idRegistro!);
  if (idRegistro == null) return;

  final res = await db.getResistenciasActivas(idRegistro);
  if (res != null) {
    // Crear una copia mutable de los datos
    final datosMutable = Map<String, dynamic>.from(res);
    
    setState(() {
      datosGuardados = datosMutable;
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _formKey.currentState?.patchValue(datosMutable);
    });
  }
}

  Future<void> _tomarFotoYReconocerTexto() async {
    final picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar imagen'),
        content: const Text('¿Desde dónde quieres obtener la imagen?'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text('Cámara'),
            onPressed: () => Navigator.pop(context, ImageSource.camera),
          ),
          TextButton.icon(
            icon: const Icon(Icons.photo_library),
            label: const Text('Galería'),
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );

    if (source == null) return;

    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    final inputImage = InputImage.fromFile(File(pickedFile.path));
    final textRecognizer =
        TextRecognizer(script: TextRecognitionScript.latin);
    final recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    _extraerValoresBT(recognizedText.text);
  }

  void _extraerValoresBT(String texto) {
    final regExp = RegExp(
      r'(BT\d{1,2})\n(\d{2,3})\s*[°º\""]?C\n(\d{2,3})\s*[°º\""]?C',
      caseSensitive: false,
    );

    final matches = regExp.allMatches(texto);
    final valores = <String, String?>{};
    for (final match in matches) {
      final bt = match.group(1)?.toUpperCase();
      final max = match.group(2);
      final min = match.group(3);
      if (bt != null && btTargets.contains(bt)) {
        valores['${bt.toLowerCase()}_max'] = max;
        valores['${bt.toLowerCase()}_min'] = min;
      }
    }
    _formKey.currentState?.patchValue(valores);
    _formKey.currentState?.validate();
  }

  Future<Map<String, dynamic>> _enviarDatosAlServidor(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(ApiRoutes.resistencias),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Datos enviados correctamente',
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Error del servidor: ${response.statusCode}',
          'response': response.body,
        };
      }
    } on http.ClientException catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.message}',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Tiempo de espera agotado',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado: ${e.toString()}',
      };
    }
  }

  Widget _buildBTFields(String bt) {
    return Column(
      children: [
        DividerSection(title: bt),
        Row(
          children: [
            Expanded(
              child: FormBuilderTextField(
                name: '${bt.toLowerCase()}_max',
                decoration: const InputDecoration(
                  labelText: 'Max',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Requerido' : null,
                onChanged: (val) async {
                  await _guardarCampo(bt, 'max', val);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FormBuilderTextField(
                name: '${bt.toLowerCase()}_min',
                decoration: const InputDecoration(
                  labelText: 'Min',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Requerido' : null,
                onChanged: (val) async {
                  await _guardarCampo(bt, 'min', val);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _cerrarYEnviarFormulario() async {
  if (_isSubmitting || _registroProvider.idRegistro == null) return;
  
  setState(() => _isSubmitting = true);
  
  try {
    final idRegistro = int.tryParse(_registroProvider.idRegistro!);
    if (idRegistro == null) return;

    // Forzar guardado de todos los campos
    _formKey.currentState?.save();
    
    // Obtener datos del formulario
    final formData = _formKey.currentState?.value ?? {};
    debugPrint('🔍 Datos del formulario: $formData');

    // Verificar datos en la base de datos local antes de enviar
    final db = DatabaseHelper();
    final datosLocales = await db.getResistenciasActivas(idRegistro);
    debugPrint('💾 Datos en DB local: $datosLocales');

    // Preparar datos para enviar
    final datosParaEnviar = {
      'id_registro': idRegistro,
      ...formData,
      'fecha_creacion': DateTime.now().toIso8601String(),
      'fecha_actualizacion': DateTime.now().toIso8601String(),
    };

    // 1. Guardar localmente (asegurar todos los campos)
    await db.actualizarResistencias(
      idRegistro: idRegistro,
      valores: formData,
    );

    // 2. Enviar al servidor
    final resultado = await _enviarDatosAlServidor(datosParaEnviar);
    
    if (resultado['success']) {
      // 3. Cerrar registro
      await db.cerrarResistencias(idRegistro);
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultado['message'])),
      );
      
      // Limpiar el formulario
      _formKey.currentState?.reset();
      
      // Opcional: Crear nuevo registro automáticamente
      
      // Recargar datos (si es necesario)
      if (mounted) {
        setState(() {});
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultado['message'])),
      );
    }
  } catch (e) {
    debugPrint('🔥 Error al enviar: ${e.toString()}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  } finally {
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }
}

Future<void> _guardarCampo(String bt, String tipo, String? valor) async {
  if (valor == null || valor.isEmpty || _registroProvider.idRegistro == null) return;
  
  final db = DatabaseHelper();
  final idRegistro = int.tryParse(_registroProvider.idRegistro!);
  if (idRegistro == null) return;

  // Debug: Mostrar campo que se está guardando
  debugPrint('💾 Guardando campo: ${bt.toLowerCase()}_$tipo = $valor');
  
  await db.guardarCampoResistencia(
    idRegistro,
    '${bt.toLowerCase()}_$tipo',
    valor,
  );

  // Verificar que se guardó correctamente
  final res = await db.getResistenciasActivas(idRegistro);
  debugPrint('📦 Datos guardados en DB: ${res?.toString()}');
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FormBuilder(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (_registroProvider.idRegistro == null)
                const Text('No hay un registro de producción activo',
                    style: TextStyle(color: Colors.red)),
              ...btTargets.map((bt) => _buildBTFields(bt)).toList(),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'foto',
            onPressed: _tomarFotoYReconocerTexto,
            backgroundColor: Colors.orange,
            child: const Icon(Icons.camera_alt, color: Colors.white),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'cerrar',
            onPressed: _cerrarYEnviarFormulario,
            backgroundColor: _isSubmitting ? Colors.grey : Colors.red,
            child: _isSubmitting 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}