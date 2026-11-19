import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/lugar.dart';

/// Persistencia local (JSON en SharedPreferences) de la bitácora.
class LugarRepository {
  static const _clave = 'lugares';

  Future<List<Lugar>> obtenerTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final texto = prefs.getString(_clave);
    if (texto == null) return [];
    return (jsonDecode(texto) as List)
        .map((e) => Lugar.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
  }

  Future<void> guardar(Lugar lugar) async {
    final lista = await obtenerTodos()
      ..removeWhere((l) => l.id == lugar.id)
      ..add(lugar);
    await _escribir(lista);
  }

  Future<void> eliminar(String id) async {
    final lista = await obtenerTodos()
      ..removeWhere((l) => l.id == id);
    await _escribir(lista);
  }

  Future<void> _escribir(List<Lugar> lista) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _clave,
      jsonEncode(lista.map((l) => l.toJson()).toList()),
    );
  }

  Future<void> cargarDemo() async {
    final hoy = DateTime.now();
    for (final l in [
      Lugar(
        id: 'demo-1',
        nombre: 'Baluarte de San Francisco',
        ciudad: 'Campeche',
        categoria: 'Centro histórico',
        calificacion: 5,
        resena: 'Murallas muy bien conservadas, ideal al atardecer.',
        latitud: 19.8438,
        longitud: -90.5370,
        temperatura: 29.4,
        clima: 'Parcialmente nublado',
        fecha: hoy.subtract(const Duration(days: 3)),
      ),
      Lugar(
        id: 'demo-2',
        nombre: 'Zona arqueológica de Edzná',
        ciudad: 'Campeche',
        categoria: 'Zona arqueológica',
        calificacion: 4,
        resena: 'El Edificio de los Cinco Pisos es impresionante.',
        latitud: 19.5967,
        longitud: -90.2297,
        temperatura: 32.1,
        clima: 'Despejado',
        fecha: hoy.subtract(const Duration(days: 1)),
      ),
    ]) {
      await guardar(l);
    }
  }
}
