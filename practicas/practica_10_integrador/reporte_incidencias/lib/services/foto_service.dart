import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Captura una fotografía con la cámara y la copia al almacenamiento de la app
/// para que siga disponible sin conexión.
class FotoService {
  final ImagePicker _picker;
  FotoService([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  /// Devuelve la ruta local o `null` si el usuario canceló.
  Future<String?> tomar({bool desdeGaleria = false}) async {
    final archivo = await _picker.pickImage(
      source: desdeGaleria ? ImageSource.gallery : ImageSource.camera,
      maxWidth: 1280,
      imageQuality: 80,
    );
    if (archivo == null) return null;
    final dir = await getApplicationDocumentsDirectory();
    final destino =
        '${dir.path}${Platform.pathSeparator}foto_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(archivo.path).copy(destino);
    return destino;
  }
}
