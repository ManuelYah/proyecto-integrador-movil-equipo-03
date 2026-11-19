import 'package:flutter/material.dart';

import '../models/clima.dart';
import '../models/lugar.dart';
import '../services/dependencias.dart';
import '../utils/formato.dart';
import '../utils/validadores.dart';
import '../widgets/estrellas.dart';
import '../widgets/fila_dato.dart';
import '../widgets/panel_clima.dart';

/// Pantalla 2: formulario validado con GPS y consulta de clima (REST).
class FormularioLugarScreen extends StatefulWidget {
  const FormularioLugarScreen({super.key});

  @override
  State<FormularioLugarScreen> createState() => _FormularioLugarScreenState();
}

class _FormularioLugarScreenState extends State<FormularioLugarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _ciudad = TextEditingController();
  final _resena = TextEditingController();
  String? _categoria;
  int _calificacion = 0;
  double? _lat;
  double? _lng;
  Clima? _clima;
  String? _errorUbicacion;
  bool _buscando = false;
  bool _guardando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _ciudad.dispose();
    _resena.dispose();
    super.dispose();
  }

  Future<void> _ubicar() async {
    final deps = Dependencias.of(context);
    setState(() {
      _buscando = true;
      _errorUbicacion = null;
    });
    try {
      final pos = await deps.ubicacion.obtener();
      setState(() {
        _lat = pos.latitud;
        _lng = pos.longitud;
      });
      final clima = await deps.clima.actual(pos.latitud, pos.longitud);
      setState(() => _clima = clima);
    } catch (e) {
      setState(() => _errorUbicacion = e.toString());
    } finally {
      if (mounted) setState(() => _buscando = false);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final deps = Dependencias.of(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _guardando = true);
    final lugar = Lugar(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: _nombre.text.trim(),
      ciudad: _ciudad.text.trim(),
      categoria: _categoria!,
      calificacion: _calificacion,
      resena: _resena.text.trim(),
      latitud: _lat,
      longitud: _lng,
      temperatura: _clima?.temperatura,
      clima: _clima?.descripcion,
      fecha: DateTime.now(),
    );
    try {
      await deps.repositorio.guardar(lugar);
      final total = (await deps.repositorio.obtenerTodos()).length;
      try {
        await deps.notificaciones.solicitarPermiso();
        await deps.notificaciones.lugarGuardado(lugar.nombre, total);
      } catch (_) {}
      messenger.showSnackBar(
        SnackBar(content: Text('${lugar.nombre} guardado')),
      );
      navigator.pop(true);
    } catch (e) {
      setState(() => _guardando = false);
      messenger.showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    }
  }

  InputDecoration _deco(String label, IconData icono) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icono),
    border: const OutlineInputBorder(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar lugar')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('campoNombre'),
              controller: _nombre,
              decoration: _deco('Nombre del lugar', Icons.place_outlined),
              validator: Validadores.nombre,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('campoCiudad'),
              controller: _ciudad,
              decoration: _deco('Ciudad', Icons.location_city),
              validator: Validadores.ciudad,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: const Key('campoCategoria'),
              initialValue: _categoria,
              decoration: _deco('Categoría', Icons.category_outlined),
              items: [
                for (final c in Lugar.categorias)
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (v) => setState(() => _categoria = v),
              validator: Validadores.categoria,
            ),
            const SizedBox(height: 12),
            FormField<int>(
              validator: (_) => Validadores.calificacion(_calificacion),
              builder: (campo) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Calificación'),
                  Estrellas(
                    valor: _calificacion,
                    tamano: 32,
                    onCambio: (v) {
                      setState(() => _calificacion = v);
                      campo.didChange(v);
                    },
                  ),
                  if (campo.hasError)
                    Text(
                      campo.errorText!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('campoResena'),
              controller: _resena,
              decoration: _deco('Reseña', Icons.rate_review_outlined),
              minLines: 2,
              maxLines: 4,
              validator: Validadores.resena,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    FilaDato(
                      icono: Icons.gps_fixed,
                      etiqueta: 'Coordenadas GPS',
                      valor: formatoCoordenadas(_lat, _lng),
                    ),
                    if (_errorUbicacion != null)
                      Text(
                        _errorUbicacion!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _buscando ? null : _ubicar,
                        icon: _buscando
                            ? const SizedBox.square(
                                dimension: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.my_location),
                        label: const Text('Ubicar y consultar clima'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_clima != null) PanelClima(clima: _clima!),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('botonGuardar'),
              onPressed: _guardando ? null : _guardar,
              icon: const Icon(Icons.save),
              label: Text(_guardando ? 'Guardando...' : 'Guardar en bitácora'),
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
