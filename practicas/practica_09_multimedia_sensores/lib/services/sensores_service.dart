import 'package:sensors_plus/sensors_plus.dart';

import '../models/registro_inspeccion.dart';

/// Fuentes de datos de sensores. Se inyectan para poder usar streams
/// falsos en las pruebas (los plugins nativos no existen en `flutter test`).
class FuenteSensores {
  final Stream<LecturaEjes> acelerometro;
  final Stream<LecturaEjes> giroscopio;

  const FuenteSensores({required this.acelerometro, required this.giroscopio});

  /// Streams reales del dispositivo. `uiInterval` (~60 Hz) evita saturar
  /// la interfaz con más eventos de los que se pueden dibujar.
  factory FuenteSensores.dispositivo() => FuenteSensores(
    acelerometro: accelerometerEventStream(
      samplingPeriod: SensorInterval.uiInterval,
    ).map((e) => LecturaEjes(e.x, e.y, e.z)),
    giroscopio: gyroscopeEventStream(samplingPeriod: SensorInterval.uiInterval)
        .map((e) => LecturaEjes(e.x, e.y, e.z)),
  );
}
