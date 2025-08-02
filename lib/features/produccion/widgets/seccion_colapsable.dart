// seccion_colapsable.dart
import 'package:flutter/material.dart';

class SeccionColapsable extends StatefulWidget {
  final String titulo;
  final Widget contenido;
  final bool inicialmenteExpandido;
  final double grosorDivider;
  final EdgeInsetsGeometry padding;
  final Color? colorCabecera;
  final TextStyle? estiloTitulo;

  const SeccionColapsable({
    super.key,
    required this.titulo,
    required this.contenido,
    this.inicialmenteExpandido = true,
    this.grosorDivider = 2,
    this.padding = const EdgeInsets.only(bottom: 16),
    this.colorCabecera,
    this.estiloTitulo,
  });

  @override
  State<SeccionColapsable> createState() => _SeccionColapsableState();
}

class _SeccionColapsableState extends State<SeccionColapsable> {
  late bool _expandido;

  @override
  void initState() {
    super.initState();
    _expandido = widget.inicialmenteExpandido;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expandido = !_expandido),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.colorCabecera ?? Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.titulo,
                    style: widget.estiloTitulo ?? TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Icon(
                    _expandido ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
            ),
          ),
          if (_expandido)
            Padding(
              padding: widget.padding,
              child: widget.contenido,
            ),
          Divider(
            thickness: widget.grosorDivider,
            height: 0,
          ),
        ],
      ),
    );
  }
}