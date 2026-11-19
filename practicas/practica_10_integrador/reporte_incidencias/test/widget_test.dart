import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:reporte_incidencias/main.dart';
import 'package:reporte_incidencias/services/api_service.dart';
import 'package:reporte_incidencias/services/dependencias.dart';
import 'package:reporte_incidencias/services/notificaciones.dart';
import 'package:reporte_incidencias/services/ubicacion_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dobles de prueba para no depender de plugins nativos.
class NotificacionesFalsas implements Notificaciones {
  final mostradas = <String>[];
  @override
  Future<void> iniciar() async {}
  @override
  Future<bool> solicitarPermiso() async => true;
  @override
  Future<void> mostrar() async => mostradas.add('ejemplo');
  @override
  Future<void> reporteGuardado(String titulo) async => mostradas.add(titulo);
}

class UbicacionFalsa implements UbicacionService {
  @override
  Future<({double latitud, double longitud})> obtener() async =>
      (latitud: 19.84, longitud: -90.52);
}

void main() {
  late NotificacionesFalsas notif;
  var falloApi = false;

  Future<void> iniciarApp(WidgetTester tester) async {
    notif = NotificacionesFalsas();
    // Pantalla de teléfono (412 x 1400 lógicos) para que el formulario
    // completo quede construido.
    tester.view.physicalSize = const Size(1236, 4200);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ReporteApp(
        dependencias: Dependencias(
          notificaciones: notif,
          ubicacion: UbicacionFalsa(),
          api: ApiService(
            MockClient((req) async {
              if (falloApi) throw http.ClientException('offline');
              return req.method == 'GET'
                  ? http.Response(
                      jsonEncode([
                        {
                          'id': 1,
                          'title': 'Corte de agua',
                          'body': 'Zona centro',
                        },
                      ]),
                      200,
                    )
                  : http.Response(jsonEncode({'id': 101}), 201);
            }),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    falloApi = false;
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('La pantalla de inicio muestra las opciones', (tester) async {
    await iniciarApp(tester);
    expect(find.text('Reporte Móvil de Incidencias'), findsOneWidget);
    expect(find.text('Nuevo reporte'), findsOneWidget);
    expect(find.text('Mis reportes'), findsOneWidget);
    expect(find.text('Sincronización y avisos'), findsOneWidget);
  });

  testWidgets('El formulario valida los campos obligatorios', (tester) async {
    await iniciarApp(tester);
    await tester.tap(find.text('Nuevo reporte'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('botonGuardar')));
    await tester.tap(find.byKey(const Key('botonGuardar')));
    await tester.pump();

    expect(find.text('El título es obligatorio'), findsOneWidget);
    expect(find.text('La descripción es obligatoria'), findsOneWidget);
    expect(find.text('Selecciona una categoría'), findsOneWidget);
    expect(notif.mostradas, isEmpty);
  });

  testWidgets('Flujo completo: guardar, notificar, listar y ver detalle', (
    tester,
  ) async {
    await iniciarApp(tester);
    await tester.tap(find.text('Nuevo reporte'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('campoTitulo')), 'Poste caído');
    await tester.enterText(
      find.byKey(const Key('campoDescripcion')),
      'Poste de luz caído sobre la banqueta',
    );
    await tester.tap(find.byKey(const Key('campoCategoria')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alumbrado').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Obtener ubicación'));
    await tester.tap(find.text('Obtener ubicación'));
    await tester.pumpAndSettle();
    expect(find.text('19.84000, -90.52000'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('botonGuardar')));
    await tester.tap(find.byKey(const Key('botonGuardar')));
    await tester.pumpAndSettle();

    expect(notif.mostradas, ['Poste caído']);
    expect(find.text('Reporte guardado'), findsOneWidget);

    await tester.tap(find.text('Mis reportes'));
    await tester.pumpAndSettle();
    expect(find.text('Poste caído'), findsOneWidget);

    await tester.tap(find.text('Poste caído'));
    await tester.pumpAndSettle();
    expect(find.text('Detalle del reporte'), findsOneWidget);
    expect(find.text('Poste de luz caído sobre la banqueta'), findsOneWidget);
  });

  testWidgets('Listado vacío permite cargar demostración', (tester) async {
    await iniciarApp(tester);
    await tester.tap(find.text('Mis reportes'));
    await tester.pumpAndSettle();
    expect(find.text('Aún no hay reportes'), findsOneWidget);
    await tester.tap(find.text('Cargar datos de demostración'));
    await tester.pumpAndSettle();
    expect(find.text('Bache frente a la escuela'), findsOneWidget);
  });

  testWidgets('Sincronización: muestra avisos y sincroniza pendientes', (
    tester,
  ) async {
    await iniciarApp(tester);
    await tester.tap(find.text('Sincronización y avisos'));
    await tester.pumpAndSettle();
    expect(find.text('Corte de agua'), findsOneWidget);
    await tester.tap(find.text('Sincronizar reportes pendientes'));
    await tester.pumpAndSettle();
    expect(find.text('No hay reportes pendientes'), findsOneWidget);
  });

  testWidgets('Sincronización: sin conexión muestra error y reintento', (
    tester,
  ) async {
    falloApi = true;
    await iniciarApp(tester);
    await tester.tap(find.text('Sincronización y avisos'));
    await tester.pumpAndSettle();
    expect(find.text('Sin conexión con el servidor.'), findsOneWidget);
    falloApi = false;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('Corte de agua'), findsOneWidget);
  });
}
