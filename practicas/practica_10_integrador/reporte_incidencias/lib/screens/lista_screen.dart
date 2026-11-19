import 'package:flutter/material.dart';

import '../models/reporte.dart';
import '../services/dependencias.dart';
import '../widgets/estado_vista.dart';
import '../widgets/tarjeta_reporte.dart';
import 'detalle_screen.dart';
import 'formulario_screen.dart';

class ListaScreen extends StatefulWidget {
  const ListaScreen({super.key});

  @override
  State<ListaScreen> createState() => _ListaScreenState();
}

class _ListaScreenState extends State<ListaScreen> {
  late Future<List<Reporte>> _futuro;
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
    setState(() {
      _futuro = Dependencias.of(context).repositorio.obtenerTodos();
    });
  }

  Future<void> _abrir(Widget pantalla) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => pantalla));
    _recargar();
  }

  Future<void> _cargarDemo() async {
    await Dependencias.of(context).repositorio.cargarDemo();
    _recargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis reportes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrir(const FormularioScreen()),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
      body: FutureBuilder<List<Reporte>>(
        future: _futuro,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Cargando(mensaje: 'Leyendo reportes locales...');
          }
          if (snap.hasError) {
            return MensajeEstado.error(
              mensaje: 'No se pudieron leer los reportes: ${snap.error}',
              onReintentar: _recargar,
            );
          }
          final reportes = snap.data!;
          if (reportes.isEmpty) {
            return MensajeEstado(
              icono: Icons.inbox_outlined,
              titulo: 'Aún no hay reportes',
              detalle: 'Crea uno nuevo o carga datos de demostración.',
              textoAccion: 'Cargar datos de demostración',
              onAccion: _cargarDemo,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _recargar(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
              itemCount: reportes.length,
              itemBuilder: (_, i) => TarjetaReporte(
                reporte: reportes[i],
                onTap: () => _abrir(DetalleScreen(reporte: reportes[i])),
              ),
            ),
          );
        },
      ),
    );
  }
}
