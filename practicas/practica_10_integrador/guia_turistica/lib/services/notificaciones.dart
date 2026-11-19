import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notificaciones locales (flutter_local_notifications 23.x).
class Notificaciones {
  final FlutterLocalNotificationsPlugin _plugin;
  bool _iniciado = false;

  Notificaciones([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _detalles = NotificationDetails(
    android: AndroidNotificationDetails(
      'canal_bitacora',
      'Bitácora de viaje',
      channelDescription: 'Avisos de la guía turística',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  Future<void> iniciar() async {
    if (_iniciado) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    _iniciado = true;
  }

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
    return await ios?.requestPermissions(alert: true, sound: true) ?? false;
  }

  Future<void> lugarGuardado(String nombre, int total) async {
    await iniciar();
    await _plugin.show(
      id: total,
      title: '¡Nuevo lugar en tu bitácora!',
      body: '$nombre agregado. Llevas $total lugar(es) visitado(s).',
      notificationDetails: _detalles,
    );
  }
}
