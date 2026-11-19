import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class UbicacionException implements Exception {
  final String mensaje;
  const UbicacionException(this.mensaje);
  @override
  String toString() => mensaje;
}

/// Obtiene latitud y longitud manejando servicio y permisos.
class UbicacionService {
  Future<({double latitud, double longitud})> obtener() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const UbicacionException('Activa el GPS del dispositivo.');
    }
    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }
    if (permiso == LocationPermission.denied) {
      throw const UbicacionException('Permiso de ubicación denegado.');
    }
    if (permiso == LocationPermission.deniedForever) {
      throw const UbicacionException(
        'Permiso denegado permanentemente. Habilítalo en Ajustes.',
      );
    }
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: _ajustes(),
    );
    return (latitud: pos.latitude, longitud: pos.longitude);
  }

  /// En Android se usa el LocationManager nativo (GPS) para no depender de
  /// Google Play Services ni de su diálogo de "Precisión de ubicación".
  LocationSettings _ajustes() {
    const limite = Duration(seconds: 20);
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        forceLocationManager: true,
        timeLimit: limite,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: limite,
    );
  }
}
