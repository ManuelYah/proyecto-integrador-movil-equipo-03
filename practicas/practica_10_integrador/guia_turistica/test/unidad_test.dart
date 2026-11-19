import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:guia_turistica/models/clima.dart';
import 'package:guia_turistica/models/lugar.dart';
import 'package:guia_turistica/services/clima_service.dart';
import 'package:guia_turistica/services/lugar_repository.dart';
import 'package:guia_turistica/utils/validadores.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _jsonClima = {
  'current': {
    'temperature_2m': 28.6,
    'relative_humidity_2m': 70,
    'wind_speed_10m': 12.3,
    'weather_code': 2,
  },
};

Lugar _lugar(String id, DateTime fecha) => Lugar(
  id: id,
  nombre: 'Malecón',
  ciudad: 'Campeche',
  categoria: 'Playa',
  calificacion: 4,
  resena: 'Muy agradable para caminar',
  latitud: 19.85,
  longitud: -90.53,
  fecha: fecha,
);

void main() {
  test('Lugar se serializa y deserializa', () {
    final l = _lugar('1', DateTime(2026, 11, 17));
    final c = Lugar.fromJson(jsonDecode(jsonEncode(l.toJson())));
    expect(c.nombre, l.nombre);
    expect(c.calificacion, 4);
    expect(c.tieneUbicacion, isTrue);
  });

  test('Clima interpreta el JSON de Open-Meteo', () {
    final c = Clima.fromJson(_jsonClima);
    expect(c.temperatura, 28.6);
    expect(c.humedad, 70);
    expect(c.descripcion, 'Parcialmente nublado');
  });

  test('Validadores', () {
    expect(Validadores.nombre(''), isNotNull);
    expect(Validadores.nombre('Edzná'), isNull);
    expect(Validadores.resena('corta'), isNotNull);
    expect(Validadores.calificacion(0), isNotNull);
    expect(Validadores.calificacion(5), isNull);
  });

  group('LugarRepository', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('guarda ordenado y elimina', () async {
      final repo = LugarRepository();
      await repo.guardar(_lugar('a', DateTime(2026, 1, 1)));
      await repo.guardar(_lugar('b', DateTime(2026, 2, 1)));
      expect((await repo.obtenerTodos()).map((l) => l.id), ['b', 'a']);
      await repo.eliminar('a');
      expect(await repo.obtenerTodos(), hasLength(1));
    });
  });

  group('ClimaService', () {
    test('consulta y envía coordenadas', () async {
      late Uri uri;
      final s = ClimaService(
        MockClient((req) async {
          uri = req.url;
          return http.Response(jsonEncode(_jsonClima), 200);
        }),
      );
      final c = await s.actual(19.85, -90.53);
      expect(c.temperatura, 28.6);
      expect(uri.queryParameters['latitude'], '19.85');
    });

    test('error HTTP', () {
      final s = ClimaService(MockClient((_) async => http.Response('x', 500)));
      expect(s.actual(0, 0), throwsA(isA<ClimaException>()));
    });

    test('JSON inválido', () {
      final s = ClimaService(MockClient((_) async => http.Response('{}', 200)));
      expect(s.actual(0, 0), throwsA(isA<ClimaException>()));
    });

    test('sin conexión', () {
      final s = ClimaService(
        MockClient((_) async => throw http.ClientException('offline')),
      );
      expect(s.actual(0, 0), throwsA(isA<ClimaException>()));
    });
  });
}
