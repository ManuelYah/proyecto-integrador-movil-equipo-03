import 'package:flutter/material.dart';

/// Fila etiqueta/valor con icono, usada en formulario y detalle.
class FilaDato extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;

  const FilaDato({
    super.key,
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(etiqueta, style: Theme.of(context).textTheme.labelMedium),
              Text(valor, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    ),
  );
}
