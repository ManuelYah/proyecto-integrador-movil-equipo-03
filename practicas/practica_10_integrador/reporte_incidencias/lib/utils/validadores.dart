/// Reglas de validación del formulario de reporte.
class Validadores {
  static String? titulo(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'El título es obligatorio';
    if (v.length < 5) return 'Mínimo 5 caracteres';
    if (v.length > 60) return 'Máximo 60 caracteres';
    return null;
  }

  static String? descripcion(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'La descripción es obligatoria';
    if (v.length < 10) return 'Describe la incidencia (mínimo 10 caracteres)';
    return null;
  }

  static String? categoria(String? valor) =>
      (valor == null || valor.isEmpty) ? 'Selecciona una categoría' : null;
}
