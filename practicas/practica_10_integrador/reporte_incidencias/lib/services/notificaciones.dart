import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Servicio de notificaciones locales (Parte A de la práctica).
///
/// Nota: con flutter_local_notifications 23.x, `initialize` y `show` usan
/// parámetros con nombre (el manual muestra `show` con parámetros
/// posicionales de versiones anteriores).
class Notificaciones {
  final FlutterLocalNotificationsPlugin _plugin;
  bool _iniciado = false;

  Notificaciones([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _detalles = NotificationDetails(
    android: AndroidNotificationDetails(
      'canal_practica',
      'Práctica móvil',
      channelDescription: 'Alertas de la aplicación',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  Future<void> iniciar() async {
    if (_iniciado) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings: settings);
    _iniciado = true;
  }

  /// Solicita el permiso POST_NOTIFICATIONS (Android 13+) o el de iOS.
  Future<bool> solicitarPermiso() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, sound: true) ?? false;
    }
    return false;
  }

  /// Ejemplo guiado del manual.
  Future<void> mostrar() => _mostrar(
    1,
    'Tópicos de Programación Móvil',
    'Tienes una actividad pendiente',
  );

  /// Notificación que se lanza después de guardar un reporte.
  Future<void> reporteGuardado(String titulo) =>
      _mostrar(2, 'Reporte guardado', '"$titulo" se guardó en el dispositivo');

  Future<void> _mostrar(int id, String titulo, String cuerpo) async {
    await iniciar();
    await _plugin.show(
      id: id,
      title: titulo,
      body: cuerpo,
      notificationDetails: _detalles,
    );
  }
}
