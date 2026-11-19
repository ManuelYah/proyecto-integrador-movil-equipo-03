# Guía Turística – Bitácora de viaje

Práctica 10 – Ejercicio evaluable (aplicación distinta al ejemplo de incidencias).
Asignatura: Tópicos de Programación Móvil.

## Objetivo

Registrar los lugares turísticos que visita el usuario con calificación,
reseña, coordenadas GPS y el clima del momento, y consultar el clima actual
de cada lugar o de la ubicación del dispositivo mediante una API REST.

## Cumplimiento de requisitos mínimos

| Requisito | Implementación |
|---|---|
| Tres pantallas como mínimo | Mis lugares, Agregar lugar, Detalle del lugar, Clima aquí (4) |
| Formulario validado | Nombre, ciudad, categoría, calificación 1–5 y reseña |
| API REST/JSON | Open-Meteo (`api.open-meteo.com/v1/forecast`), sin llave |
| Persistencia local | `shared_preferences` con JSON (`LugarRepository`) |
| Capacidad del dispositivo | GPS con `geolocator` |
| Notificación | Notificación local al agregar un lugar |
| Arquitectura organizada | `models/`, `services/`, `screens/`, `widgets/`, `utils/` + inyección de dependencias |
| Estados de carga/error | `Cargando`, `MensajeEstado.error` con reintento en cada consulta |
| Ejecución en dispositivo | Probado en emulador Android API 36 |

## Estructura

```
lib/
├── main.dart
├── models/        # Lugar, Clima (interpreta códigos WMO)
├── services/      # LugarRepository, ClimaService, UbicacionService, Notificaciones
├── screens/       # inicio (NavigationBar), mis_lugares, formulario_lugar, detalle_lugar, clima_aqui
├── widgets/       # Estrellas, TarjetaLugar, PanelClima, estados, FilaDato
└── utils/         # Validadores, formato e iconos
test/              # 12 pruebas: unitarias (modelo, API con MockClient, repositorio) y de widgets
docs/evidencias/practica-10/
```

## Requisitos

- Flutter 3.47.2 / Dart 3.13.2, Android SDK con `compileSdk` 37.

| Paquete | Versión |
|---|---|
| flutter_local_notifications | 23.0.2 |
| geolocator | 14.1.2 |
| shared_preferences | 2.5.6 |
| http | 1.6.0 |
| intl | 0.20.3 |

## Instalación y ejecución

```bash
flutter pub get
flutter run
```

```bash
dart format .
flutter analyze
flutter test
```

## Pruebas

- `flutter analyze`: sin problemas.
- `flutter test`: 12 pruebas aprobadas.
- Casos manuales (emulador API 36): bitácora vacía, validación, GPS + clima,
  guardado con notificación, detalle con clima actual, error sin conexión y
  reintento. Capturas en `docs/evidencias/practica-10/`.

## Problemas conocidos

- En el primer arranque en modo *debug* en un emulador con poca memoria,
  Android puede mostrar "La app no responde"; basta con elegir *Esperar*.
  No ocurre en ejecuciones posteriores ni en modo *release*.
- El clima depende de conexión a internet; sin ella se muestra el error y el
  botón de reintento, y la bitácora sigue disponible.

## Participantes

| Nombre | Matrícula |
|---|---|
| Angel Andrei León Aguilar | 8950 |
