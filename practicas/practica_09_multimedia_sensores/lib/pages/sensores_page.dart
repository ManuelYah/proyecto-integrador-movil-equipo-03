import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/registro_inspeccion.dart';
import '../services/camara_service.dart';
import '../services/sensores_service.dart';

/// Ejemplo guiado del manual + ampliación con giroscopio.
class SensoresPage extends StatefulWidget {
  final FuenteSensores? fuente;
  final SelectorImagen selector;

  const SensoresPage({super.key, this.fuente, this.selector = abrirCamara});

  @override
  State<SensoresPage> createState() => _SensoresPageState();
}

class _SensoresPageState extends State<SensoresPage> {
  XFile? foto;
  LecturaEjes acel = LecturaEjes.cero;
  LecturaEjes giro = LecturaEjes.cero;
  final List<StreamSubscription<LecturaEjes>> _subs = [];

  @override
  void initState() {
    super.initState();
    final fuente = widget.fuente ?? FuenteSensores.dispositivo();
    _subs.add(
      fuente.acelerometro.listen(
        (e) {
          if (mounted) setState(() => acel = e);
        },
        onError: (_) {},
        cancelOnError: true,
      ),
    );
    _subs.add(
      fuente.giroscopio.listen(
        (e) {
          if (mounted) setState(() => giro = e);
        },
        onError: (_) {},
        cancelOnError: true,
      ),
    );
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  Future<void> tomarFoto() async {
    final r = await capturarFoto(widget.selector);
    if (!mounted) return;
    if (r.estado == EstadoCaptura.ok) {
      setState(() => foto = r.archivo);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(r.mensaje!)));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Cámara y acelerómetro')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        FilledButton.icon(
          onPressed: tomarFoto,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Tomar fotografía'),
        ),
        const SizedBox(height: 12),
        if (foto != null) Image.file(File(foto!.path), height: 250),
        const Divider(),
        Text('Acelerómetro X: ${acel.x.toStringAsFixed(2)}'),
        Text('Acelerómetro Y: ${acel.y.toStringAsFixed(2)}'),
        Text('Acelerómetro Z: ${acel.z.toStringAsFixed(2)}'),
        const Divider(),
        Text('Giroscopio X: ${giro.x.toStringAsFixed(2)}'),
        Text('Giroscopio Y: ${giro.y.toStringAsFixed(2)}'),
        Text('Giroscopio Z: ${giro.z.toStringAsFixed(2)}'),
      ],
    ),
  );
}
