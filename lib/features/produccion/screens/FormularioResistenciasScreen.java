import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:produccionapp/widgets/seccion_colapsable.dart'; // Ajusta la ruta

class FormularioResistenciasScreen extends StatefulWidget {
  final String idRegistro;

  const FormularioResistenciasScreen({super.key, required this.idRegistro});

  @override
  State<FormularioResistenciasScreen> createState() => _FormularioResistenciasScreenState();
}

class _FormularioResistenciasScreenState extends State<FormularioResistenciasScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Formulario Resistencias")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                // Sección BT11-BT25
                SeccionColapsable(
                  titulo: "Sección BT11 - BT25",
                  contenido: SingleChildScrollView(
                    child: Column(
                      children: [
                        const Text("Contenido de la sección BT"),
                        const SizedBox(height: 20),
                        FormBuilderTextField(
                          name: 'campo_bt',
                          decoration: const InputDecoration(
                            labelText: 'Ejemplo BT',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Otra sección colapsable
                SeccionColapsable(
                  titulo: "Otra Sección",
                  inicialmenteExpandido: false,
                  contenido: Column(
                    children: [
                      const Text("Contenido de otra sección"),
                      const SizedBox(height: 20),
                      FormBuilderTextField(
                        name: 'otro_campo',
                        decoration: const InputDecoration(
                          labelText: 'Otro campo',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      final values = _formKey.currentState!.value;
                      print('Datos guardados: $values');
                    } else {
                      print('Formulario inválido');
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}