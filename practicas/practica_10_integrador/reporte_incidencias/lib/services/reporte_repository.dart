import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/reporte.dart';

/// Persistencia local de reportes. Los datos quedan disponibles sin conexión.
class ReporteRepository {
  static const _clave = 'reportes';

  Future<List<Reporte>> obtenerTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final texto = prefs.getString(_clave);
    if (texto == null) return [];
    final lista = (jsonDecode(texto) as List)
        .map((e) => Reporte.fromJson(e as Map<String, dynamic>))
        .toList();
    lista.sort((a, b) => b.fecha.compareTo(a.fecha));
    return lista;
  }

  Future<void> guardar(Reporte reporte) async {
    final lista = await obtenerTodos();
    lista.removeWhere((r) => r.id == reporte.id);
    lista.add(reporte);
    await _escribir(lista);
  }

  Future<void> eliminar(String id) async {
    final lista = await obtenerTodos()
      ..removeWhere((r) => r.id == id);
    await _escribir(lista);
  }

  Future<void> _escribir(List<Reporte> lista) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _clave,
      jsonEncode(lista.map((r) => r.toJson()).toList()),
    );
  }

  /// Datos de demostración para probar el listado y el detalle.
  Future<void> cargarDemo() async {
    final ahora = DateTime.now();
    final demo = [
      Reporte(
        id: 'demo-1',
        titulo: 'Lámpara fundida en el parque',
        descripcion:
            'La lámpara de la entrada norte no enciende desde hace '
            'tres noches y la zona queda a oscuras.',
        categoria: 'Alumbrado',
        latitud: 19.8301,
        longitud: -90.5349,
        fecha: ahora.subtract(const Duration(days: 2)),
        sincronizado: true,
      ),
      Reporte(
        id: 'demo-2',
        titulo: 'Bache frente a la escuela',
        descripcion:
            'Bache profundo en el carril derecho, peligroso para '
            'motocicletas y bicicletas.',
        categoria: 'Baches',
        latitud: 19.8455,
        longitud: -90.5233,
        fecha: ahora.subtract(const Duration(hours: 5)),
      ),
    ];
    for (final r in demo) {
      await guardar(r);
    }
  }
}
