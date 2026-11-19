# Reporte Móvil de Incidencias

Práctica 10 – Notificaciones y Proyecto Móvil Integrador (ejemplo guiado).
Asignatura: Tópicos de Programación Móvil.

## Objetivo

Integrar en una aplicación Flutter las competencias del curso (formularios,
capacidades nativas, persistencia, consumo de API REST y notificaciones
locales) mediante una app para reportar incidencias de la comunidad.

## Funciones

| Requisito del manual | Implementación |
|---|---|
| Pantalla de inicio y navegación | `InicioScreen` con contadores y menú |
| Formulario validado (título, descripción, categoría) | `FormularioScreen` + `utils/validadores.dart` |
| Captura de fotografía | `image_picker` (cámara o galería), copia al almacenamiento de la app |
| Latitud y longitud | `geolocator` con LocationManager nativo en Android |
| Fecha y hora del reporte | Se registra al abrir el formulario |
| Persistencia local | `shared_preferences` (JSON) en `ReporteRepository` |
| Listado sin conexión | `ListaScreen` (lee solo del almacenamiento local) |
| Pantalla de detalle | `DetalleScreen` (foto, datos, sincronizar, eliminar) |
| API REST / sincronización | `ApiService` contra JSONPlaceholder (GET avisos, POST reportes) |
| Notificación local al guardar | `flutter_local_notifications` (`Notificaciones.reporteGuardado`) |
| Componentes reutilizables y carpetas | `widgets/`, `services/`, `screens/`, `models/`, `utils/` |
| Manejo de errores y permisos | Estados de carga/error/vacío, mensajes de permiso de GPS, cámara y notificaciones |

## Estructura

```
lib/
├── main.dart                 # Arranque, tema e inyección de dependencias
├── models/                   # Reporte, Aviso
├── services/                 # Repositorio, API, ubicación, foto, notificaciones
├── screens/                  # Inicio, formulario, lista, detalle, sincronización
├── widgets/                  # Tarjetas, estados de carga/error, filas de datos
└── utils/                    # Validadores y formato
test/
├── unidad_test.dart          # Modelo, validadores, repositorio, API (MockClient)
└── widget_test.dart          # Flujos de UI con dobles de prueba
docs/evidencias/practica-10/  # Capturas de ejecución
```

## Requisitos

- Flutter 3.47.2 (stable) / Dart 3.13.2
- Android SDK con `compileSdk` 37 (exigido por flutter_local_notifications 23)
- Dispositivo o emulador Android 7.0+ (probado en emulador API 36)

| Paquete | Versión |
|---|---|
| flutter_local_notifications | 23.0.2 |
| image_picker | 1.2.4 |
| geolocator | 14.1.2 |
| shared_preferences | 2.5.6 |
| http | 1.6.0 |
| path_provider | 2.1.6 |
| intl | 0.20.3 |

## Instalación y ejecución

```bash
flutter pub get
flutter run
```

Comprobaciones de calidad:

```bash
dart format .
flutter analyze
flutter test
```

Generar APK: `flutter build apk`.

## Configuración nativa realizada

- `android/app/build.gradle.kts`: `compileSdk = 37`, *core library desugaring*
  (`desugar_jdk_libs 2.1.4`), requerido por flutter_local_notifications.
- `AndroidManifest.xml`: permisos `INTERNET`, `POST_NOTIFICATIONS`,
  `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`.
- `ios/Runner/Info.plist`: descripciones de uso de ubicación, cámara y fotos.

## Pruebas

- `flutter analyze`: sin problemas.
- `flutter test`: 17 pruebas aprobadas (unitarias y de widgets).
- Pruebas manuales en emulador Android API 36: ver `docs/evidencias/practica-10/`
  y el reporte de la práctica.

## Problemas conocidos

- La API usada (JSONPlaceholder) es de prueba: acepta el POST pero no guarda
  los datos; la sincronización es simulada.
- La fotografía no se envía al servidor (solo los datos del reporte).
- El ejemplo del manual usa `plugin.show(1, ...)` con parámetros posicionales;
  en la versión 23 la firma es `show(id:, title:, body:, notificationDetails:)`.

## Participantes

| Nombre | Matrícula |
|---|---|
| Angel Andrei León Aguilar | 8950 |
