/// Lectura de un sensor de tres ejes en un instante dado.
class LecturaEjes {
  final double x;
  final double y;
  final double z;

  const LecturaEjes(this.x, this.y, this.z);

  static const cero = LecturaEjes(0, 0, 0);

  String formato() =>
      'X: ${x.toStringAsFixed(2)}  Y: ${y.toStringAsFixed(2)}  Z: ${z.toStringAsFixed(2)}';
}

/// Registro de la bitácora: foto + fecha/hora + valores de sensores
/// congelados en el momento de la captura.
class RegistroInspeccion {
  final String rutaFoto;
  final DateTime fechaHora;
  final LecturaEjes acelerometro;
  final LecturaEjes giroscopio;

  const RegistroInspeccion({
    required this.rutaFoto,
    required this.fechaHora,
    required this.acelerometro,
    required this.giroscopio,
  });
}
