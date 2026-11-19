import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:reporte_incidencias/models/reporte.dart';
import 'package:reporte_incidencias/services/api_service.dart';
import 'package:reporte_incidencias/services/reporte_repository.dart';
import 'package:reporte_incidencias/utils/validadores.dart';
import 'package:shared_preferences/shared_preferences.dart';

Reporte _reporte(String id, {DateTime? fecha}) => Reporte(
  id: id,
  titulo: 'Fuga de agua',
  descripcion: 'Fuga constante en la esquina',
  categoria: 'Agua y drenaje',
  latitud: 19.8,
  longitud: -90.5,
  fecha: fecha ?? DateTime(2026, 11, 17, 10, 30),
);

void main() {
  group('Modelo Reporte', () {
    test('toJson / fromJson conserva los datos', () {
      final r = _reporte('1');
      final copia = Reporte.fromJson(jsonDecode(jsonEncode(r.toJson())));
      expect(copia.titulo, r.titulo);
      expect(copia.latitud, 19.8);
      expect(copia.fecha, r.fecha);
      expect(copia.sincronizado, isFalse);
      expect(copia.tieneUbicacion, isTrue);
    });

    test('copyWith marca como sincronizado', () {
      expect(_reporte('1').copyWith(sincronizado: true).sincronizado, isTrue);
    });
  });

  group('Validadores', () {
    test('título', () {
      expect(Validadores.titulo(''), isNotNull);
      expect(Validadores.titulo('abc'), isNotNull);
      expect(Validadores.titulo('Bache grande'), isNull);
    });
    test('descripción', () {
      expect(Validadores.descripcion('corta'), isNotNull);
      expect(Validadores.descripcion('Descripción suficiente'), isNull);
    });
    test('categoría', () {
      expect(Validadores.categoria(null), isNotNull);
      expect(Validadores.categoria('Baches'), isNull);
    });
  });

  group('ReporteRepository', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('guarda, ordena por fecha y elimina', () async {
      final repo = ReporteRepository();
      await repo.guardar(_reporte('a', fecha: DateTime(2026, 1, 1)));
      await repo.guardar(_reporte('b', fecha: DateTime(2026, 6, 1)));
      var lista = await repo.obtenerTodos();
      expect(lista.map((r) => r.id), ['b', 'a']);

      await repo.guardar(lista.last.copyWith(sincronizado: true));
      lista = await repo.obtenerTodos();
      expect(lista.length, 2);
      expect(lista.firstWhere((r) => r.id == 'a').sincronizado, isTrue);

      await repo.eliminar('b');
      expect((await repo.obtenerTodos()).single.id, 'a');
    });

    test('carga datos de demostración', () async {
      final repo = ReporteRepository();
      await repo.cargarDemo();
      expect(await repo.obtenerTodos(), hasLength(2));
    });
  });

  group('ApiService', () {
    test('obtiene avisos', () async {
      final api = ApiService(
        MockClient(
          (req) async => http.Response(
            jsonEncode([
              {'id': 1, 'title': 'Aviso', 'body': 'Contenido'},
            ]),
            200,
          ),
        ),
      );
      final avisos = await api.obtenerAvisos();
      expect(avisos.single.titulo, 'Aviso');
    });

    test('error HTTP produce ApiException', () async {
      final api = ApiService(MockClient((_) async => http.Response('', 500)));
      expect(api.obtenerAvisos(), throwsA(isA<ApiException>()));
    });

    test('sin conexión produce ApiException', () async {
      final api = ApiService(
        MockClient((_) async => throw http.ClientException('offline')),
      );
      expect(api.obtenerAvisos(), throwsA(isA<ApiException>()));
    });

    test('sincronizar envía JSON y devuelve id', () async {
      late Map<String, dynamic> enviado;
      final api = ApiService(
        MockClient((req) async {
          enviado = jsonDecode(req.body);
          return http.Response(jsonEncode({'id': 101}), 201);
        }),
      );
      expect(await api.sincronizar(_reporte('1')), 101);
      expect(enviado['titulo'], 'Fuga de agua');
      expect(enviado.containsKey('fotoPath'), isFalse);
    });
  });
}
