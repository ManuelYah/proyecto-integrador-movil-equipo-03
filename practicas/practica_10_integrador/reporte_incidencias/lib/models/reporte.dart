/// Modelo de un reporte de incidencia.
///
/// Se serializa a JSON para guardarlo localmente y para enviarlo a la API.
class Reporte {
  final String id;
  final String titulo;
  final String descripcion;
  final String categoria;
  final String? fotoPath;
  final double? latitud;
  final double? longitud;
  final DateTime fecha;
  final bool sincronizado;

  const Reporte({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.fecha,
    this.fotoPath,
    this.latitud,
    this.longitud,
    this.sincronizado = false,
  });

  static const categorias = [
    'Alumbrado',
    'Baches',
    'Basura',
    'Agua y drenaje',
    'Seguridad',
    'Otro',
  ];

  bool get tieneUbicacion => latitud != null && longitud != null;

  Reporte copyWith({bool? sincronizado}) => Reporte(
    id: id,
    titulo: titulo,
    descripcion: descripcion,
    categoria: categoria,
    fotoPath: fotoPath,
    latitud: latitud,
    longitud: longitud,
    fecha: fecha,
    sincronizado: sincronizado ?? this.sincronizado,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'descripcion': descripcion,
    'categoria': categoria,
    'fotoPath': fotoPath,
    'latitud': latitud,
    'longitud': longitud,
    'fecha': fecha.toIso8601String(),
    'sincronizado': sincronizado,
  };

  factory Reporte.fromJson(Map<String, dynamic> json) => Reporte(
    id: json['id'] as String,
    titulo: json['titulo'] as String,
    descripcion: json['descripcion'] as String,
    categoria: json['categoria'] as String,
    fotoPath: json['fotoPath'] as String?,
    latitud: (json['latitud'] as num?)?.toDouble(),
    longitud: (json['longitud'] as num?)?.toDouble(),
    fecha: DateTime.parse(json['fecha'] as String),
    sincronizado: json['sincronizado'] as bool? ?? false,
  );
}
