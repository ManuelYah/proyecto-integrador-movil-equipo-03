import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/registro_inspeccion.dart';

class TarjetaEvidencia extends StatelessWidget {
  final RegistroInspeccion registro;
  final int numero;

  const TarjetaEvidencia({
    super.key,
    required this.registro,
    required this.numero,
  });

  @override
  Widget build(BuildContext context) {
    final fecha = DateFormat('dd/MM/yyyy HH:mm:ss').format(registro.fechaHora);
    final tema = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.file(
            File(registro.rutaFoto),
            height: 220,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              height: 220,
              color: tema.colorScheme.surfaceContainerHighest,
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image, size: 48),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Evidencia #$numero', style: tema.textTheme.titleMedium),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 18),
                    const SizedBox(width: 6),
                    Text(fecha),
                  ],
                ),
                const Divider(),
                _fila(
                  Icons.speed,
                  'Acelerómetro (m/s²)',
                  registro.acelerometro,
                ),
                const SizedBox(height: 8),
                _fila(
                  Icons.threesixty,
                  'Giroscopio (rad/s)',
                  registro.giroscopio,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fila(IconData icono, String titulo, LecturaEjes l) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icono, size: 18),
      const SizedBox(width: 6),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(l.formato()),
          ],
        ),
      ),
    ],
  );
}
