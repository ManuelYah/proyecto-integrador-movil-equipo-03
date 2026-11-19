import 'package:flutter/material.dart';

import '../models/clima.dart';
import '../services/dependencias.dart';
import '../utils/formato.dart';
import '../widgets/estado_vista.dart';
import '../widgets/panel_clima.dart';

/// Pantalla 4: clima en la ubicación actual (GPS + API REST).
class ClimaAquiScreen extends StatefulWidget {
  const ClimaAquiScreen({super.key});

  @override
  State<ClimaAquiScreen> createState() => _ClimaAquiScreenState();
}

enum _Estado { inicial, cargando, listo, error }

class _ClimaAquiScreenState extends State<ClimaAquiScreen> {
  _Estado _estado = _Estado.inicial;
  Clima? _clima;
  String? _error;
  double? _lat;
  double? _lng;

  Future<void> _consultar() async {
    final deps = Dependencias.of(context);
    setState(() => _estado = _Estado.cargando);
    try {
      final pos = await deps.ubicacion.obtener();
      final clima = await deps.clima.actual(pos.latitud, pos.longitud);
      setState(() {
        _lat = pos.latitud;
        _lng = pos.longitud;
        _clima = clima;
        _estado = _Estado.listo;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _estado = _Estado.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clima en mi ubicación')),
      body: switch (_estado) {
        _Estado.inicial => MensajeEstado(
          icono: Icons.wb_sunny_outlined,
          titulo: '¿Qué clima hace donde estás?',
          detalle: 'Usa el GPS del dispositivo y la API de Open-Meteo.',
          textoAccion: 'Consultar clima',
          onAccion: _consultar,
        ),
        _Estado.cargando => const Cargando(
          mensaje: 'Obteniendo ubicación y clima...',
        ),
        _Estado.error => MensajeEstado.error(
          mensaje: _error!,
          onReintentar: _consultar,
        ),
        _Estado.listo => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            PanelClima(clima: _clima!),
            ListTile(
              leading: const Icon(Icons.gps_fixed),
              title: const Text('Tu ubicación'),
              subtitle: Text(formatoCoordenadas(_lat, _lng)),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _consultar,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
            ),
          ],
        ),
      },
    );
  }
}
