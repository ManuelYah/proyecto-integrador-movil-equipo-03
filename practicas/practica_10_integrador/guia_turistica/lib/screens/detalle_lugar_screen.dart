import 'package:flutter/material.dart';

import '../models/clima.dart';
import '../models/lugar.dart';
import '../services/dependencias.dart';
import '../utils/formato.dart';
import '../widgets/estado_vista.dart';
import '../widgets/estrellas.dart';
import '../widgets/fila_dato.dart';
import '../widgets/panel_clima.dart';

/// Pantalla 3: detalle del lugar y clima actual en sus coordenadas.
class DetalleLugarScreen extends StatefulWidget {
  final Lugar lugar;
  const DetalleLugarScreen({super.key, required this.lugar});

  @override
  State<DetalleLugarScreen> createState() => _DetalleLugarScreenState();
}

class _DetalleLugarScreenState extends State<DetalleLugarScreen> {
  Future<Clima>? _clima;
  bool _iniciado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_iniciado) {
      _iniciado = true;
      _consultar();
    }
  }

  void _consultar() {
    final l = widget.lugar;
    if (!l.tieneUbicacion) return;
    final futuro = Dependencias.of(context).clima
        .actual(l.latitud!, l.longitud!);
    setState(() {
      _clima = futuro;
    });
  }

  Future<void> _eliminar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar lugar'),
        content: Text('¿Quitar "${widget.lugar.nombre}" de la bitácora?'),
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
    if (ok != true || !mounted) return;
    await Dependencias.of(context).repositorio.eliminar(widget.lugar.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.lugar;
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del lugar'),
        actions: [
          IconButton(
            tooltip: 'Eliminar',
            onPressed: _eliminar,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: tema.colorScheme.secondaryContainer,
                child: Icon(iconoCategoria(l.categoria), size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.nombre, style: tema.textTheme.headlineSmall),
                    Text('${l.ciudad} · ${l.categoria}'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Estrellas(valor: l.calificacion, tamano: 28),
          const SizedBox(height: 12),
          Text(l.resena, style: tema.textTheme.bodyLarge),
          const Divider(height: 32),
          FilaDato(
            icono: Icons.event,
            etiqueta: 'Visitado el',
            valor: formatoFecha(l.fecha),
          ),
          FilaDato(
            icono: Icons.gps_fixed,
            etiqueta: 'Coordenadas',
            valor: formatoCoordenadas(l.latitud, l.longitud),
          ),
          if (l.temperatura != null)
            FilaDato(
              icono: Icons.history,
              etiqueta: 'Clima durante la visita',
              valor: '${l.temperatura!.toStringAsFixed(1)} °C · ${l.clima}',
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Clima actual', style: tema.textTheme.titleMedium),
              const Spacer(),
              if (_clima != null)
                IconButton(
                  tooltip: 'Actualizar',
                  onPressed: _consultar,
                  icon: const Icon(Icons.refresh),
                ),
            ],
          ),
          if (_clima == null)
            const Text('Este lugar no tiene coordenadas registradas.')
          else
            FutureBuilder<Clima>(
              future: _clima,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Cargando(mensaje: 'Consultando Open-Meteo...'),
                  );
                }
                if (snap.hasError) {
                  return MensajeEstado.error(
                    mensaje: '${snap.error}',
                    onReintentar: _consultar,
                  );
                }
                return PanelClima(clima: snap.data!);
              },
            ),
        ],
      ),
    );
  }
}
