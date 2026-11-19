import 'package:flutter/material.dart';

import '../models/lugar.dart';
import '../services/dependencias.dart';
import '../widgets/estado_vista.dart';
import '../widgets/tarjeta_lugar.dart';
import 'detalle_lugar_screen.dart';
import 'formulario_lugar_screen.dart';

/// Pantalla 1: bitácora de lugares visitados (persistencia local).
class MisLugaresScreen extends StatefulWidget {
  const MisLugaresScreen({super.key});

  @override
  State<MisLugaresScreen> createState() => _MisLugaresScreenState();
}

class _MisLugaresScreenState extends State<MisLugaresScreen> {
  late Future<List<Lugar>> _futuro;
  bool _iniciado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_iniciado) {
      _iniciado = true;
      _recargar();
    }
  }

  void _recargar() {
    final futuro = Dependencias.of(context).repositorio.obtenerTodos();
    setState(() {
      _futuro = futuro;
    });
  }

  Future<void> _abrir(Widget pantalla) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => pantalla));
    _recargar();
  }

  Future<void> _demo() async {
    await Dependencias.of(context).repositorio.cargarDemo();
    _recargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guía Turística · Mi bitácora')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrir(const FormularioLugarScreen()),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Agregar lugar'),
      ),
      body: FutureBuilder<List<Lugar>>(
        future: _futuro,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Cargando(mensaje: 'Cargando bitácora...');
          }
          if (snap.hasError) {
            return MensajeEstado.error(
              mensaje: '${snap.error}',
              onReintentar: _recargar,
            );
          }
          final lugares = snap.data!;
          if (lugares.isEmpty) {
            return MensajeEstado(
              icono: Icons.travel_explore,
              titulo: 'Tu bitácora está vacía',
              detalle: 'Agrega el primer lugar que visites.',
              textoAccion: 'Cargar datos de demostración',
              onAccion: _demo,
            );
          }
          final promedio =
              lugares.map((l) => l.calificacion).reduce((a, b) => a + b) /
              lugares.length;
          return RefreshIndicator(
            onRefresh: () async => _recargar(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
              children: [
                _Resumen(total: lugares.length, promedio: promedio),
                for (final l in lugares)
                  TarjetaLugar(
                    lugar: l,
                    onTap: () => _abrir(DetalleLugarScreen(lugar: l)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Resumen extends StatelessWidget {
  final int total;
  final double promedio;
  const _Resumen({required this.total, required this.promedio});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final color = tema.colorScheme.onPrimary;
    return Card(
      color: tema.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            for (final (valor, etiqueta) in [
              ('$total', 'Lugares'),
              (promedio.toStringAsFixed(1), 'Calificación media'),
            ])
              Expanded(
                child: Column(
                  children: [
                    Text(
                      valor,
                      style: tema.textTheme.headlineMedium?.copyWith(
                        color: color,
                      ),
                    ),
                    Text(
                      etiqueta,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: color),
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
