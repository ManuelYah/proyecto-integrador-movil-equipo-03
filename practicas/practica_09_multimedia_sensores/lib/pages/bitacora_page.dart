import 'dart:async';

import 'package:flutter/material.dart';

import '../models/registro_inspeccion.dart';
import '../services/camara_service.dart';
import '../services/sensores_service.dart';
import '../widgets/tarjeta_evidencia.dart';

/// Ejercicio evaluable: bitácora de inspección.
/// Al capturar una foto se congelan fecha/hora y los valores actuales
/// del acelerómetro y giroscopio en una tarjeta de evidencia.
class BitacoraPage extends StatefulWidget {
  final FuenteSensores? fuente;
  final SelectorImagen selector;
  final DateTime Function() reloj;

  const BitacoraPage({
    super.key,
    this.fuente,
    this.selector = abrirCamara,
    this.reloj = DateTime.now,
  });

  @override
  State<BitacoraPage> createState() => _BitacoraPageState();
}

class _BitacoraPageState extends State<BitacoraPage> {
  // Los valores se guardan en ValueNotifier para que sólo el panel en vivo
  // se redibuje con cada evento, no toda la lista de tarjetas.
  final _acel = ValueNotifier<LecturaEjes>(LecturaEjes.cero);
  final _giro = ValueNotifier<LecturaEjes>(LecturaEjes.cero);
  final List<StreamSubscription<LecturaEjes>> _subs = [];
  final List<RegistroInspeccion> _registros = [];
  bool _acelDisponible = true;
  bool _giroDisponible = true;
  bool _capturando = false;

  @override
  void initState() {
    super.initState();
    final fuente = widget.fuente ?? FuenteSensores.dispositivo();
    _subs.add(
      fuente.acelerometro.listen(
        (e) => _acel.value = e,
        onError: (_) {
          if (mounted) setState(() => _acelDisponible = false);
        },
        cancelOnError: true,
      ),
    );
    _subs.add(
      fuente.giroscopio.listen(
        (e) => _giro.value = e,
        onError: (_) {
          if (mounted) setState(() => _giroDisponible = false);
        },
        cancelOnError: true,
      ),
    );
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _acel.dispose();
    _giro.dispose();
    super.dispose();
  }

  Future<void> _nuevaEvidencia() async {
    if (_capturando) return;
    setState(() => _capturando = true);
    final r = await capturarFoto(widget.selector);
    if (!mounted) return;
    setState(() {
      _capturando = false;
      if (r.estado == EstadoCaptura.ok) {
        _registros.insert(
          0,
          RegistroInspeccion(
            rutaFoto: r.archivo!.path,
            fechaHora: widget.reloj(),
            acelerometro: _acel.value,
            giroscopio: _giro.value,
          ),
        );
      }
    });
    if (r.estado != EstadoCaptura.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(r.mensaje!),
          backgroundColor: r.estado == EstadoCaptura.cancelada
              ? null
              : Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bitácora de inspección')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _capturando ? null : _nuevaEvidencia,
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Nueva evidencia'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          _PanelEnVivo(
            acel: _acel,
            giro: _giro,
            acelDisponible: _acelDisponible,
            giroDisponible: _giroDisponible,
          ),
          const SizedBox(height: 16),
          if (_registros.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Sin evidencias. Pulsa "Nueva evidencia" para capturar.',
                textAlign: TextAlign.center,
              ),
            ),
          for (var i = 0; i < _registros.length; i++)
            TarjetaEvidencia(
              registro: _registros[i],
              numero: _registros.length - i,
            ),
        ],
      ),
    );
  }
}

class _PanelEnVivo extends StatelessWidget {
  final ValueNotifier<LecturaEjes> acel;
  final ValueNotifier<LecturaEjes> giro;
  final bool acelDisponible;
  final bool giroDisponible;

  const _PanelEnVivo({
    required this.acel,
    required this.giro,
    required this.acelDisponible,
    required this.giroDisponible,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lectura en vivo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('Acelerómetro'),
            acelDisponible
                ? ValueListenableBuilder<LecturaEjes>(
                    valueListenable: acel,
                    builder: (_, v, _) =>
                        Text(v.formato(), key: const Key('acelVivo')),
                  )
                : const Text('No disponible en este dispositivo'),
            const SizedBox(height: 8),
            const Text('Giroscopio'),
            giroDisponible
                ? ValueListenableBuilder<LecturaEjes>(
                    valueListenable: giro,
                    builder: (_, v, _) =>
                        Text(v.formato(), key: const Key('giroVivo')),
                  )
                : const Text('No disponible en este dispositivo'),
          ],
        ),
      ),
    );
  }
}
