# Práctica 10 – Notificaciones y Proyecto Móvil Integrador

Tópicos de Programación Móvil · ITESCAM

## Objetivo

Integrar las competencias del curso en una aplicación móvil funcional y
configurar notificaciones locales como base conceptual para alertas al usuario.

## Contenido del repositorio

| Carpeta | Descripción |
|---|---|
| [`reporte_incidencias/`](reporte_incidencias/) | Ejemplo guiado: **Reporte Móvil de Incidencias** (formulario validado, foto, GPS, fecha y hora, persistencia local, listado sin conexión, detalle, API REST con sincronización y notificación local). |
| [`guia_turistica/`](guia_turistica/) | Ejercicio evaluable: **Guía Turística**, bitácora de lugares visitados con GPS, clima en tiempo real (API Open-Meteo), persistencia local y notificación. |

Cada proyecto tiene su propio README con el detalle de funciones, estructura,
pruebas y problemas conocidos, y sus evidencias en `docs/evidencias/practica-10/`.

## Requisitos

- Flutter 3.47.2 (stable) / Dart 3.13.2
- Android SDK con `compileSdk` 37
- Dispositivo o emulador Android 7.0 o superior

## Instalación y ejecución

```bash
cd reporte_incidencias      # o: cd guia_turistica
flutter pub get
flutter run
```

## Pruebas

```bash
dart format .
flutter analyze
flutter test
```

| Proyecto | flutter analyze | flutter test |
|---|---|---|
| reporte_incidencias | Sin problemas | 17 pruebas aprobadas |
| guia_turistica | Sin problemas | 12 pruebas aprobadas |

Los resultados completos están en
`*/docs/evidencias/practica-10/resultados_pruebas.txt`.

## Participantes

| Nombre | Matrícula |
|---|---|
| Angel Andrei León Aguilar | 8950 |
