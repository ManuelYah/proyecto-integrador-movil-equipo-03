import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/aviso.dart';
import '../models/reporte.dart';

class ApiException implements Exception {
  final String mensaje;
  const ApiException(this.mensaje);
  @override
  String toString() => mensaje;
}

/// Consumo de API REST (JSONPlaceholder) para avisos y sincronización.
class ApiService {
  static const baseUrl = 'https://jsonplaceholder.typicode.com';
  static const _timeout = Duration(seconds: 10);

  final http.Client _client;
  ApiService([http.Client? client]) : _client = client ?? http.Client();

  Future<List<Aviso>> obtenerAvisos() async {
    final resp = await _ejecutar(
      () => _client.get(Uri.parse('$baseUrl/posts?_limit=10')),
    );
    if (resp.statusCode != 200) {
      throw ApiException('El servidor respondió ${resp.statusCode}');
    }
    final datos = jsonDecode(resp.body) as List;
    return datos.map((e) => Aviso.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Envía el reporte al servidor. Devuelve el id asignado por la API.
  Future<int> sincronizar(Reporte reporte) async {
    final datos = reporte.toJson()..remove('fotoPath');
    final resp = await _ejecutar(
      () => _client.post(
        Uri.parse('$baseUrl/posts'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(datos),
      ),
    );
    if (resp.statusCode != 201) {
      throw ApiException('No se pudo sincronizar (${resp.statusCode})');
    }
    return (jsonDecode(resp.body) as Map<String, dynamic>)['id'] as int;
  }

  Future<http.Response> _ejecutar(Future<http.Response> Function() fn) async {
    try {
      return await fn().timeout(_timeout);
    } on TimeoutException {
      throw const ApiException('Tiempo de espera agotado. Revisa tu conexión.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Sin conexión con el servidor.');
    }
  }
}
