import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:practica09_sensores/models/registro_inspeccion.dart';
import 'package:practica09_sensores/pages/bitacora_page.dart';
import 'package:practica09_sensores/services/camara_service.dart';
import 'package:practica09_sensores/services/sensores_service.dart';

void main() {
  group('capturarFoto', () {
    test('devuelve cancelada cuando el usuario cierra la cámara', () async {
      final r = await capturarFoto(() async => null);
      expect(r.estado, EstadoCaptura.cancelada);
    });

    test('detecta permiso denegado', () async {
      final r = await capturarFoto(
        () async => throw PlatformException(code: 'camera_access_denied'),
      );
      expect(r.estado, EstadoCaptura.sinPermiso);
    });

    test('devuelve la foto cuando la captura es correcta', () async {
      final r = await capturarFoto(() async => XFile('/tmp/foto.jpg'));
      expect(r.estado, EstadoCaptura.ok);
      expect(r.archivo!.path, '/tmp/foto.jpg');
    });
  });

  group('BitacoraPage', () {
    late StreamController<LecturaEjes> acel;
    late StreamController<LecturaEjes> giro;

    setUp(() {
      acel = StreamController<LecturaEjes>.broadcast();
      giro = StreamController<LecturaEjes>.broadcast();
    });

    tearDown(() {
      acel.close();
      giro.close();
    });

    Widget app(SelectorImagen selector) => MaterialApp(
      home: BitacoraPage(
        fuente: FuenteSensores(
          acelerometro: acel.stream,
          giroscopio: giro.stream,
        ),
        selector: selector,
        reloj: () => DateTime(2026, 11, 17, 10, 30, 5),
      ),
    );

    testWidgets('muestra lecturas en vivo de acelerómetro y giroscopio', (
      t,
    ) async {
      await t.pumpWidget(app(() async => null));
      acel.add(const LecturaEjes(1.5, -2, 9.81));
      giro.add(const LecturaEjes(0.1, 0.2, 0.3));
      await t.pump();

      expect(find.text('X: 1.50  Y: -2.00  Z: 9.81'), findsOneWidget);
      expect(find.text('X: 0.10  Y: 0.20  Z: 0.30'), findsOneWidget);
    });

    testWidgets('crea una tarjeta con fecha y valores congelados', (t) async {
      await t.pumpWidget(app(() async => XFile('no_existe.jpg')));
      acel.add(const LecturaEjes(1, 2, 3));
      giro.add(const LecturaEjes(4, 5, 6));
      await t.pump();

      await t.tap(find.text('Nueva evidencia'));
      await t.pump();

      // Los sensores siguen cambiando; la tarjeta conserva el valor capturado.
      acel.add(const LecturaEjes(9, 9, 9));
      await t.pump();

      expect(find.text('Evidencia #1'), findsOneWidget);
      expect(find.text('17/11/2026 10:30:05'), findsOneWidget);
      expect(find.text('X: 1.00  Y: 2.00  Z: 3.00'), findsOneWidget);
      expect(find.text('X: 4.00  Y: 5.00  Z: 6.00'), findsNWidgets(2));
    });

    testWidgets('maneja la cancelación de la cámara', (t) async {
      await t.pumpWidget(app(() async => null));
      await t.tap(find.text('Nueva evidencia'));
      await t.pump();

      expect(find.text('Captura cancelada por el usuario'), findsOneWidget);
      expect(find.textContaining('Evidencia #'), findsNothing);
    });

    testWidgets('informa cuando falta el permiso de cámara', (t) async {
      await t.pumpWidget(
        app(() async => throw PlatformException(code: 'camera_access_denied')),
      );
      await t.tap(find.text('Nueva evidencia'));
      await t.pump();

      expect(find.textContaining('Permiso de cámara denegado'), findsOneWidget);
    });

    testWidgets('indica sensor no disponible si el stream falla', (t) async {
      await t.pumpWidget(app(() async => null));
      giro.addError(Exception('sin giroscopio'));
      await t.pump();

      expect(find.text('No disponible en este dispositivo'), findsOneWidget);
    });
  });
}
