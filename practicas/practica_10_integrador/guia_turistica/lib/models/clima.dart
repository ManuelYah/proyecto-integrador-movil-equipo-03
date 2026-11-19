/// Clima actual devuelto por la API REST de Open-Meteo.
class Clima {
  final double temperatura;
  final int humedad;
  final double viento;
  final int codigo;

  const Clima({
    required this.temperatura,
    required this.humedad,
    required this.viento,
    required this.codigo,
  });

  factory Clima.fromJson(Map<String, dynamic> json) {
    final c = json['current'] as Map<String, dynamic>;
    return Clima(
      temperatura: (c['temperature_2m'] as num).toDouble(),
      humedad: (c['relative_humidity_2m'] as num).toInt(),
      viento: (c['wind_speed_10m'] as num).toDouble(),
      codigo: (c['weather_code'] as num).toInt(),
    );
  }

  /// Descripción en español del código WMO.
  String get descripcion => switch (codigo) {
    0 => 'Despejado',
    1 || 2 => 'Parcialmente nublado',
    3 => 'Nublado',
    45 || 48 => 'Niebla',
    >= 51 && <= 57 => 'Llovizna',
    >= 61 && <= 67 => 'Lluvia',
    >= 71 && <= 77 => 'Nieve',
    >= 80 && <= 82 => 'Chubascos',
    >= 95 => 'Tormenta',
    _ => 'Variable',
  };
}
