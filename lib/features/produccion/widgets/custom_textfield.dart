import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class CustomFormBuilderTextField extends StatelessWidget {
  final String name;
  final String label;
  final String hintText;
  final int maxLines;
  final FormFieldValidator<String>? validator; // ✅ Tipo de función opcional

  const CustomFormBuilderTextField({
    super.key,
    required this.name,
    required this.label,
    required this.hintText,
    this.maxLines = 1,
    this.validator, // ✅ Ya no es requerido
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: name,
      maxLines: maxLines,
      validator: validator, // ✅ Se pasa directamente
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
