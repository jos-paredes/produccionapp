import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:produccionapp/features/produccion/widgets/seccion_colapsable.dart';

class FormularioResistenciasScreen extends StatefulWidget {
  final String idRegistro;

  const FormularioResistenciasScreen({super.key, required this.idRegistro});

  @override
  State<FormularioResistenciasScreen> createState() => _FormularioResistenciasScreenState();
}

class _FormularioResistenciasScreenState extends State<FormularioResistenciasScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final List<String> _bts = List.generate(15, (index) => 'BT${index + 11}'); // BT11 a BT25

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Formulario Resistencias")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FormBuilder(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Sección de Resistencias BT
                  SeccionColapsable(
                    titulo: "Resistencias BT11-BT25",
                    contenido: Column(
                      children: _bts.map((bt) => _buildResistenciaBT(bt)).toList(),
                    ),
                    colorCabecera: Colors.blue[100],
                  ),

                  // Sección de Configuración
                  SeccionColapsable(
                    titulo: "Configuración",
                    inicialmenteExpandido: false,
                    contenido: Column(
                      children: [
                        FormBuilderSwitch(
                          name: 'habilitar_ajustes',
                          title: const Text('Habilitar ajustes automáticos'),
                          initialValue: true,
                        ),
                        const SizedBox(height: 16),
                        FormBuilderSlider(
                          name: 'nivel_precision',
                          min: 1,
                          max: 10,
                          initialValue: 5,
                          divisions: 9,
                          label: 'Nivel de precisión',
                        ),
                      ],
                    ),
                    colorCabecera: Colors.green[100],
                  ),

                  // Sección de Comentarios
                  SeccionColapsable(
                    titulo: "Observaciones",
                    inicialmenteExpandido: false,
                    contenido: Column(
                      children: [
                        FormBuilderTextField(
                          name: 'comentarios',
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Ingrese sus comentarios',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FormBuilderCheckbox(
                          name: 'requiere_revision',
                          title: const Text('Requiere revisión adicional'),
                        ),
                      ],
                    ),
                    colorCabecera: Colors.orange[100],
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _guardarFormulario,
                      icon: const Icon(Icons.save),
                      label: const Text('GUARDAR FORMULARIO'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResistenciaBT(String bt) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(bt, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: '${bt}_max',
                  decoration: const InputDecoration(
                    labelText: 'Valor Máx',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FormBuilderTextField(
                  name: '${bt}_min',
                  decoration: const InputDecoration(
                    labelText: 'Valor Mín',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _guardarFormulario() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Formulario guardado correctamente')),
      );
      print(values);
    }
  }
}