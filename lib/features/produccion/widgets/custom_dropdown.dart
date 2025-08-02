import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class CustomFormBuilderDropdown<T> extends StatelessWidget {
  final String name;
  final String label;
  final String hintText;
  final List<T> items;

  const CustomFormBuilderDropdown({
    super.key,
    required this.name,
    required this.label,
    required this.hintText,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderDropdown<T>(
      name: name,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map((item) => DropdownMenuItem<T>(
        value: item,
        child: Text(item.toString()),
      ))
          .toList(),
    );
  }
}
