import 'package:flutter/material.dart';

import '../models/reporte.dart';
import '../services/dependencias.dart';
import '../widgets/opcion_menu.dart';
import 'formulario_screen.dart';
import 'lista_screen.dart';
import 'sincronizacion_screen.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  List<Reporte> _reportes = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cargar();
  }

  Future<void> _cargar() async {
    final lista = await Dependencias.of(context).repositorio.obtenerTodos();
    if (mounted) setState(() => _reportes = lista);
  }

  Future<void> _ir(Widget pantalla) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => pantalla));
    _cargar();
  }

  Future<void> _probarNotificacion() async {
    final notif = Dependencias.of(context).notificaciones;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await notif.solicitarPermiso();
      await notif.mostrar();
      messenger.showSnackBar(
        const SnackBar(content: Text('Notificación enviada')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo notificar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendientes = _reportes.where((r) => !r.sincronizado).length;
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Reporte Móvil de Incidencias')),
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: tema.colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reporta problemas de tu comunidad',
                      style: tema.textTheme.titleLarge?.copyWith(
                        color: tema.colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _Contador(
                          valor: _reportes.length,
                          etiqueta: 'Reportes',
                        ),
                        const SizedBox(width: 32),
                        _Contador(valor: pendientes, etiqueta: 'Pendientes'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            OpcionMenu(
              icono: Icons.add_a_photo_outlined,
              titulo: 'Nuevo reporte',
              subtitulo: 'Foto, ubicación y descripción',
              onTap: () => _ir(const FormularioScreen()),
            ),
            OpcionMenu(
              icono: Icons.list_alt,
              titulo: 'Mis reportes',
              subtitulo: 'Disponibles sin conexión',
              onTap: () => _ir(const ListaScreen()),
            ),
            OpcionMenu(
              icono: Icons.sync,
              titulo: 'Sincronización y avisos',
              subtitulo: 'API REST del servidor',
              onTap: () => _ir(const SincronizacionScreen()),
            ),
            OpcionMenu(
              icono: Icons.notifications_active_outlined,
              titulo: 'Probar notificación',
              subtitulo: 'Ejemplo guiado (Parte A)',
              onTap: _probarNotificacion,
            ),
          ],
        ),
      ),
    );
  }
}

class _Contador extends StatelessWidget {
  final int valor;
  final String etiqueta;
  const _Contador({required this.valor, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onPrimary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$valor',
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(color: color),
        ),
        Text(etiqueta, style: TextStyle(color: color)),
      ],
    );
  }
}
