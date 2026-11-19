import 'dart:io';

import 'package:flutter/material.dart';

import '../models/reporte.dart';
import '../utils/formato.dart';

class TarjetaReporte extends StatelessWidget {
  final Reporte reporte;
  final VoidCallback onTap;

  const TarjetaReporte({super.key, required this.reporte, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final foto = reporte.fotoPath;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox.square(
            dimension: 52,
            child: foto != null && File(foto).existsSync()
                ? Image.file(File(foto), fit: BoxFit.cover)
                : ColoredBox(
                    color: esquema.primaryContainer,
                    child: Icon(
                      iconoCategoria(reporte.categoria),
                      color: esquema.onPrimaryContainer,
                    ),
                  ),
          ),
        ),
        title: Text(
          reporte.titulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('${reporte.categoria} · ${formatoFecha(reporte.fecha)}'),
        trailing: Tooltip(
          message: reporte.sincronizado ? 'Sincronizado' : 'Pendiente',
          child: Icon(
            reporte.sincronizado ? Icons.cloud_done : Icons.cloud_upload,
            color: reporte.sincronizado ? Colors.green : esquema.outline,
          ),
        ),
      ),
    );
  }
}
