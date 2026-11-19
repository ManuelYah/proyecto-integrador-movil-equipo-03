class Validadores {
  static String? requerido(String? v, String mensaje, {int minimo = 3}) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return mensaje;
    if (t.length < minimo) return 'Mínimo $minimo caracteres';
    return null;
  }

  static String? nombre(String? v) => requerido(v, 'El nombre es obligatorio');
  static String? ciudad(String? v) => requerido(v, 'La ciudad es obligatoria');
  static String? resena(String? v) =>
      requerido(v, 'La reseña es obligatoria', minimo: 10);
  static String? categoria(String? v) =>
      (v == null || v.isEmpty) ? 'Selecciona una categoría' : null;
  static String? calificacion(int? v) =>
      (v == null || v < 1 || v > 5) ? 'Califica de 1 a 5 estrellas' : null;
}
