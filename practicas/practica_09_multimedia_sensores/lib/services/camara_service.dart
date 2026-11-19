import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// Resultado posible de un intento de captura.
enum EstadoCaptura { ok, cancelada, sinPermiso, error }

class ResultadoCaptura {
  final EstadoCaptura estado;
  final XFile? archivo;
  final String? mensaje;

  const ResultadoCaptura(this.estado, {this.archivo, this.mensaje});
}

/// Firma de la función que abre la cámara. Se inyecta para poder
/// sustituirla en las pruebas.
typedef SelectorImagen = Future<XFile?> Function();

Future<XFile?> abrirCamara() =>
    ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 75);

/// Envuelve la captura y traduce cancelación y errores de permisos.
Future<ResultadoCaptura> capturarFoto([
  SelectorImagen selector = abrirCamara,
]) async {
  try {
    final archivo = await selector();
    if (archivo == null) {
      return const ResultadoCaptura(
        EstadoCaptura.cancelada,
        mensaje: 'Captura cancelada por el usuario',
      );
    }
    return ResultadoCaptura(EstadoCaptura.ok, archivo: archivo);
  } on PlatformException catch (e) {
    final sinPermiso =
        e.code == 'camera_access_denied' ||
        e.code == 'photo_access_denied' ||
        e.code.contains('denied');
    return ResultadoCaptura(
      sinPermiso ? EstadoCaptura.sinPermiso : EstadoCaptura.error,
      mensaje: sinPermiso
          ? 'Permiso de cámara denegado. Habilítalo en Ajustes.'
          : 'No se pudo abrir la cámara: ${e.message ?? e.code}',
    );
  } catch (e) {
    return ResultadoCaptura(
      EstadoCaptura.error,
      mensaje: 'Error inesperado: $e',
    );
  }
}
