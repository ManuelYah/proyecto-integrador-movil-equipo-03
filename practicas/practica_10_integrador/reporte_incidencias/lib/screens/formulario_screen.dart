import 'dart:io';

import 'package:flutter/material.dart';

import '../models/reporte.dart';
import '../services/dependencias.dart';
import '../utils/formato.dart';
import '../utils/validadores.dart';
import '../widgets/fila_dato.dart';

class FormularioScreen extends StatefulWidget {
  const FormularioScreen({super.key});

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _descripcion = TextEditingController();
  final _fecha = DateTime.now();
  String? _categoria;
  String? _fotoPath;
  double? _lat;
  double? _lng;
  bool _buscandoUbicacion = false;
  bool _guardando = false;

  @override
  void dispose() {
    _titulo.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  void _mensaje(String texto) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(texto)));

  Future<void> _tomarFoto({bool galeria = false}) async {
    try {
      final ruta = await Dependencias.of(context).foto
          .tomar(desdeGaleria: galeria);
      if (ruta != null) setState(() => _fotoPath = ruta);
    } catch (e) {
      _mensaje('No se pudo obtener la foto. Revisa el permiso de cámara.');
    }
  }

  Future<void> _obtenerUbicacion() async {
    setState(() => _buscandoUbicacion = true);
    try {
      final pos = await Dependencias.of(context).ubicacion.obtener();
      setState(() {
        _lat = pos.latitud;
        _lng = pos.longitud;
      });
    } catch (e) {
      _mensaje(e.toString());
    } finally {
      if (mounted) setState(() => _buscandoUbicacion = false);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final deps = Dependencias.of(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _guardando = true);
    final reporte = Reporte(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: _titulo.text.trim(),
      descripcion: _descripcion.text.trim(),
      categoria: _categoria!,
      fotoPath: _fotoPath,
      latitud: _lat,
      longitud: _lng,
      fecha: _fecha,
    );
    try {
      await deps.repositorio.guardar(reporte);
    } catch (e) {
      setState(() => _guardando = false);
      _mensaje('Error al guardar: $e');
      return;
    }
    // La notificación no debe impedir el guardado si falla o no hay permiso.
    try {
      await deps.notificaciones.solicitarPermiso();
      await deps.notificaciones.reporteGuardado(reporte.titulo);
    } catch (_) {}
    messenger.showSnackBar(const SnackBar(content: Text('Reporte guardado')));
    navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo reporte')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('campoTitulo'),
              controller: _titulo,
              decoration: const InputDecoration(
                labelText: 'Título',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              maxLength: 60,
              textInputAction: TextInputAction.next,
              validator: Validadores.titulo,
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('campoDescripcion'),
              controller: _descripcion,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                prefixIcon: Icon(Icons.notes),
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              minLines: 3,
              maxLines: 5,
              validator: Validadores.descripcion,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: const Key('campoCategoria'),
              initialValue: _categoria,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                prefixIcon: Icon(Icons.category_outlined),
                border: OutlineInputBorder(),
              ),
              items: [
                for (final c in Reporte.categorias)
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (v) => setState(() => _categoria = v),
              validator: Validadores.categoria,
            ),
            const SizedBox(height: 16),
            _SeccionFoto(
              fotoPath: _fotoPath,
              onCamara: () => _tomarFoto(),
              onGaleria: () => _tomarFoto(galeria: true),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    FilaDato(
                      icono: Icons.schedule,
                      etiqueta: 'Fecha y hora',
                      valor: formatoFecha(_fecha),
                    ),
                    FilaDato(
                      icono: Icons.place_outlined,
                      etiqueta: 'Latitud, longitud',
                      valor: formatoCoordenadas(_lat, _lng),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _buscandoUbicacion
                            ? null
                            : _obtenerUbicacion,
                        icon: _buscandoUbicacion
                            ? const SizedBox.square(
                                dimension: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.my_location),
                        label: const Text('Obtener ubicación'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('botonGuardar'),
              onPressed: _guardando ? null : _guardar,
              icon: const Icon(Icons.save),
              label: Text(_guardando ? 'Guardando...' : 'Guardar reporte'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeccionFoto extends StatelessWidget {
  final String? fotoPath;
  final VoidCallback onCamara;
  final VoidCallback onGaleria;

  const _SeccionFoto({
    required this.fotoPath,
    required this.onCamara,
    required this.onGaleria,
  });

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: fotoPath == null
                ? ColoredBox(
                    color: esquema.surfaceContainerHighest,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.photo_camera_outlined, size: 48),
                          Text('Sin fotografía'),
                        ],
                      ),
                    ),
                  )
                : Image.file(File(fotoPath!), fit: BoxFit.cover),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: onCamara,
                icon: const Icon(Icons.photo_camera),
                label: const Text('Cámara'),
              ),
              TextButton.icon(
                onPressed: onGaleria,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galería'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
