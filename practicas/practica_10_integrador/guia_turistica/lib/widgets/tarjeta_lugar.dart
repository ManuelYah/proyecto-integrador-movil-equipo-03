import 'package:flutter/material.dart';

import '../models/lugar.dart';
import '../utils/formato.dart';
import 'estrellas.dart';

class TarjetaLugar extends StatelessWidget {
  final Lugar lugar;
  final VoidCallback onTap;
  const TarjetaLugar({super.key, required this.lugar, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: esquema.secondaryContainer,
          child: Icon(
            iconoCategoria(lugar.categoria),
            color: esquema.onSecondaryContainer,
          ),
        ),
        title: Text(lugar.nombre, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${lugar.ciudad} · ${lugar.categoria}'),
            Estrellas(valor: lugar.calificacion, tamano: 16),
          ],
        ),
        trailing: lugar.temperatura == null
            ? null
            : Text(
                '${lugar.temperatura!.toStringAsFixed(0)}°C',
                style: Theme.of(context).textTheme.titleMedium,
              ),
      ),
    );
  }
}
