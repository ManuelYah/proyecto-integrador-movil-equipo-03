/// Lugar turístico visitado por el usuario.
class Lugar {
  final String id;
  final String nombre;
  final String ciudad;
  final String categoria;
  final int calificacion;
  final String resena;
  final double? latitud;
  final double? longitud;
  final double? temperatura;
  final String? clima;
  final DateTime fecha;

  const Lugar({
    required this.id,
    required this.nombre,
    required this.ciudad,
    required this.categoria,
    required this.calificacion,
    required this.resena,
    required this.fecha,
    this.latitud,
    this.longitud,
    this.temperatura,
    this.clima,
  });

  static const categorias = [
    'Playa',
    'Museo',
    'Zona arqueológica',
    'Gastronomía',
    'Naturaleza',
    'Centro histórico',
    'Otro',
  ];

  bool get tieneUbicacion => latitud != null && longitud != null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'ciudad': ciudad,
    'categoria': categoria,
    'calificacion': calificacion,
    'resena': resena,
    'latitud': latitud,
    'longitud': longitud,
    'temperatura': temperatura,
    'clima': clima,
    'fecha': fecha.toIso8601String(),
  };

  factory Lugar.fromJson(Map<String, dynamic> j) => Lugar(
    id: j['id'] as String,
    nombre: j['nombre'] as String,
    ciudad: j['ciudad'] as String,
    categoria: j['categoria'] as String,
    calificacion: j['calificacion'] as int,
    resena: j['resena'] as String,
    latitud: (j['latitud'] as num?)?.toDouble(),
    longitud: (j['longitud'] as num?)?.toDouble(),
    temperatura: (j['temperatura'] as num?)?.toDouble(),
    clima: j['clima'] as String?,
    fecha: DateTime.parse(j['fecha'] as String),
  );
}
