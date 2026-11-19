import 'package:flutter/material.dart';

import '../models/aviso.dart';
import '../services/dependencias.dart';
import '../widgets/estado_vista.dart';

/// Sección adicional que consume la API REST: avisos y sincronización.
class SincronizacionScreen extends StatefulWidget {
  const SincronizacionScreen({super.key});

  @override
  State<SincronizacionScreen> createState() => _SincronizacionScreenState();
}

class _SincronizacionScreenState extends State<SincronizacionScreen> {
  late Future<List<Aviso>> _avisos;
  bool _iniciado = false;
  bool _sincronizando = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_iniciado) {
      _iniciado = true;
      _cargarAvisos();
    }
  }

  void _cargarAvisos() {
    final futuro = Dependencias.of(context).api.obtenerAvisos();
    setState(() {
      _avisos = futuro;
    });
  }

  Future<void> _sincronizarPendientes() async {
    final deps = Dependencias.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sincronizando = true);
    var enviados = 0;
    try {
      final pendientes = (await deps.repositorio.obtenerTodos()).where(
        (r) => !r.sincronizado,
      );
      for (final r in pendientes) {
        await deps.api.sincronizar(r);
        await deps.repositorio.guardar(r.copyWith(sincronizado: true));
        enviados++;
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            enviados == 0
                ? 'No hay reportes pendientes'
                : '$enviados reporte(s) sincronizado(s)',
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Sincronizados $enviados. Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _sincronizando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sincronización y avisos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: _sincronizando ? null : _sincronizarPendientes,
              icon: _sincronizando
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              label: const Text('Sincronizar reportes pendientes'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Avisos del servidor',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Actualizar',
                  onPressed: _cargarAvisos,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Aviso>>(
              future: _avisos,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Cargando(mensaje: 'Consultando la API...');
                }
                if (snap.hasError) {
                  return MensajeEstado.error(
                    mensaje: snap.error.toString(),
                    onReintentar: _cargarAvisos,
                  );
                }
                final avisos = snap.data!;
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: avisos.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) => ListTile(
                    leading: CircleAvatar(child: Text('${avisos[i].id}')),
                    title: Text(
                      avisos[i].titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      avisos[i].cuerpo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
