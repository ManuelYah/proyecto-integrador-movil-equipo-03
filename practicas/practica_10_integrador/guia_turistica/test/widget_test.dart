import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guia_turistica/main.dart';
import 'package:guia_turistica/models/clima.dart';
import 'package:guia_turistica/services/clima_service.dart';
import 'package:guia_turistica/services/dependencias.dart';
import 'package:guia_turistica/services/notificaciones.dart';
import 'package:guia_turistica/services/ubicacion_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificacionesFalsas implements Notificaciones {
  final enviadas = <String>[];
  @override
  Future<void> iniciar() async {}
  @override
  Future<bool> solicitarPermiso() async => true;
  @override
  Future<void> lugarGuardado(String nombre, int total) async =>
      enviadas.add('$nombre/$total');
}

class UbicacionFalsa implements UbicacionService {
  @override
  Future<({double latitud, double longitud})> obtener() async =>
      (latitud: 19.85, longitud: -90.53);
}

class ClimaFalso implements ClimaService {
  bool fallar = false;
  @override
  Future<Clima> actual(double lat, double lng) async {
    if (fallar) throw const ClimaException('Sin conexión a internet.');
    return const Clima(temperatura: 30, humedad: 60, viento: 8, codigo: 0);
  }
}

void main() {
  late NotificacionesFalsas notif;
  late ClimaFalso clima;

  Future<void> iniciar(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1236, 4200);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    notif = NotificacionesFalsas();
    clima = ClimaFalso();
    await tester.pumpWidget(
      GuiaApp(
        dependencias: Dependencias(
          notificaciones: notif,
          ubicacion: UbicacionFalsa(),
          clima: clima,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Bitácora vacía y carga de demostración', (tester) async {
    await iniciar(tester);
    expect(find.text('Tu bitácora está vacía'), findsOneWidget);
    await tester.tap(find.text('Cargar datos de demostración'));
    await tester.pumpAndSettle();
    expect(find.text('Zona arqueológica de Edzná'), findsOneWidget);
  });

  testWidgets('El formulario valida campos y calificación', (tester) async {
    await iniciar(tester);
    await tester.tap(find.text('Agregar lugar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('botonGuardar')));
    await tester.pump();
    expect(find.text('El nombre es obligatorio'), findsOneWidget);
    expect(find.text('Califica de 1 a 5 estrellas'), findsOneWidget);
    expect(notif.enviadas, isEmpty);
  });

  testWidgets('Flujo completo: agregar, notificar y ver detalle', (
    tester,
  ) async {
    await iniciar(tester);
    await tester.tap(find.text('Agregar lugar'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('campoNombre')), 'Fuerte');
    await tester.enterText(find.byKey(const Key('campoCiudad')), 'Campeche');
    await tester.tap(find.byKey(const Key('campoCategoria')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Museo').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('estrella4')));
    await tester.enterText(
      find.byKey(const Key('campoResena')),
      'Museo de arqueología maya',
    );
    await tester.tap(find.text('Ubicar y consultar clima'));
    await tester.pumpAndSettle();
    expect(find.text('30.0 °C'), findsOneWidget);

    await tester.tap(find.byKey(const Key('botonGuardar')));
    await tester.pumpAndSettle();
    expect(notif.enviadas, ['Fuerte/1']);
    expect(find.text('Fuerte'), findsOneWidget);

    await tester.tap(find.text('Fuerte'));
    await tester.pumpAndSettle();
    expect(find.text('Detalle del lugar'), findsOneWidget);
    expect(find.text('Despejado'), findsOneWidget);
  });

  testWidgets('Clima aquí muestra error y permite reintentar', (tester) async {
    await iniciar(tester);
    await tester.tap(find.text('Clima aquí'));
    await tester.pumpAndSettle();
    clima.fallar = true;
    await tester.tap(find.text('Consultar clima'));
    await tester.pumpAndSettle();
    expect(find.text('Sin conexión a internet.'), findsOneWidget);
    clima.fallar = false;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('30.0 °C'), findsOneWidget);
  });
}
