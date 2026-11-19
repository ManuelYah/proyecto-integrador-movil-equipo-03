import 'package:flutter/material.dart';

/// Calificación con estrellas. Si [onCambio] es nulo, es de solo lectura.
class Estrellas extends StatelessWidget {
  final int valor;
  final ValueChanged<int>? onCambio;
  final double tamano;

  const Estrellas({
    super.key,
    required this.valor,
    this.onCambio,
    this.tamano = 20,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 1; i <= 5; i++)
        onCambio == null
            ? Icon(
                i <= valor ? Icons.star : Icons.star_border,
                size: tamano,
                color: Colors.amber,
              )
            : IconButton(
                key: Key('estrella$i'),
                onPressed: () => onCambio!(i),
                icon: Icon(
                  i <= valor ? Icons.star : Icons.star_border,
                  size: tamano,
                  color: Colors.amber,
                ),
              ),
    ],
  );
}
