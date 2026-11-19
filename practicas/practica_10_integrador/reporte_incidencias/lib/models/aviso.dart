/// Aviso publicado por el servidor (obtenido de la API REST).
class Aviso {
  final int id;
  final String titulo;
  final String cuerpo;

  const Aviso({required this.id, required this.titulo, required this.cuerpo});

  factory Aviso.fromJson(Map<String, dynamic> json) => Aviso(
    id: json['id'] as int,
    titulo: json['title'] as String,
    cuerpo: json['body'] as String,
  );
}
