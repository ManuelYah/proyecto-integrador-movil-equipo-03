import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/clima.dart';

class ClimaException implements Exception {
  final String mensaje;
  const ClimaException(this.mensaje);
  @override
  String toString() => mensaje;
}

/// Cliente REST/JSON de Open-Meteo (no requiere llave de API).
class ClimaService {
  final http.Client _client;
  ClimaService([http.Client? client]) : _client = client ?? http.Client();

  Future<Clima> actual(double lat, double lng) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '$lat',
      'longitude': '$lng',
      'current':
          'temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code',
      'timezone': 'auto',
    });
    final http.Response resp;
    try {
      resp = await _client.get(uri).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw const ClimaException('El servicio de clima tardó demasiado.');
    } catch (_) {
      throw const ClimaException('Sin conexión a internet.');
    }
    if (resp.statusCode != 200) {
      throw ClimaException('Error del servidor (${resp.statusCode}).');
    }
    try {
      return Clima.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
    } catch (_) {
      throw const ClimaException('Respuesta de clima no válida.');
    }
  }
}
