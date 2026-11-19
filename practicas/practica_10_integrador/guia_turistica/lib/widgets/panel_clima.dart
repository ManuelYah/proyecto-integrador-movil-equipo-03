import 'package:flutter/material.dart';

import '../models/clima.dart';
import '../utils/formato.dart';

/// Tarjeta que muestra el clima actual obtenido de la API.
class PanelClima extends StatelessWidget {
  final Clima clima;
  const PanelClima({super.key, required this.clima});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      color: tema.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              iconoClima(clima.codigo),
              size: 48,
              color: tema.colorScheme.onTertiaryContainer,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${clima.temperatura.toStringAsFixed(1)} °C',
                    style: tema.textTheme.headlineSmall,
                  ),
                  Text(clima.descripcion),
                  Text(
                    'Humedad ${clima.humedad}% · Viento '
                    '${clima.viento.toStringAsFixed(0)} km/h',
                    style: tema.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
