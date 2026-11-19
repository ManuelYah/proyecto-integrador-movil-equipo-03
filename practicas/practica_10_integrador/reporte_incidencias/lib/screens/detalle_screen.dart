import 'dart:io';

import 'package:flutter/material.dart';

import '../models/reporte.dart';
import '../services/dependencias.dart';
import '../utils/formato.dart';
import '../widgets/fila_dato.dart';

class DetalleScreen extends StatefulWidget {
  final Reporte reporte;
  const DetalleScreen({super.key, required this.reporte});

  @override
  State<DetalleScreen> createState() => _DetalleScreenState();
}

class _DetalleScreenState extends State<DetalleScreen> {
  late Reporte _reporte = widget.reporte;
  bool _sincronizando = false;

  Future<void> _sincronizar() async {
    final deps = Dependencias.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sincronizando = true);
    try {
      final idServidor = await deps.api.sincronizar(_reporte);
      final actualizado = _reporte.copyWith(sincronizado: true);
      await deps.repositorio.guardar(actualizado);
      setState(() => _reporte = actualizado);
      messenger.showSnackBar(
        SnackBar(content: Text('Sincronizado (id servidor: $idServidor)')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _sincronizando = false);
    }
  }

  Future<void> _eliminar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar reporte'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    await Dependencias.of(context).repositorio.eliminar(_reporte.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final foto = _reporte.fotoPath;
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del reporte'),
        actions: [
          IconButton(
            tooltip: 'Eliminar',
            onPressed: _eliminar,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        children: [
          if (foto != null && File(foto).existsSync())
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.file(File(foto), fit: BoxFit.cover),
            )
          else
            Container(
              height: 160,
              color: tema.colorScheme.primaryContainer,
              child: Icon(
                iconoCategoria(_reporte.categoria),
                size: 72,
                color: tema.colorScheme.onPrimaryContainer,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_reporte.titulo, style: tema.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      avatar: Icon(iconoCategoria(_reporte.categoria)),
                      label: Text(_reporte.categoria),
                    ),
                    Chip(
                      avatar: Icon(
                        _reporte.sincronizado
                            ? Icons.cloud_done
                            : Icons.cloud_upload,
                      ),
                      label: Text(
                        _reporte.sincronizado ? 'Sincronizado' : 'Pendiente',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(_reporte.descripcion, style: tema.textTheme.bodyLarge),
                const Divider(height: 32),
                FilaDato(
                  icono: Icons.schedule,
                  etiqueta: 'Fecha y hora',
                  valor: formatoFecha(_reporte.fecha),
                ),
                FilaDato(
                  icono: Icons.place_outlined,
                  etiqueta: 'Latitud, longitud',
                  valor: formatoCoordenadas(
                    _reporte.latitud,
                    _reporte.longitud,
                  ),
                ),
                const SizedBox(height: 24),
                if (!_reporte.sincronizado)
                  FilledButton.icon(
                    onPressed: _sincronizando ? null : _sincronizar,
                    icon: _sincronizando
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: const Text('Sincronizar con el servidor'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
