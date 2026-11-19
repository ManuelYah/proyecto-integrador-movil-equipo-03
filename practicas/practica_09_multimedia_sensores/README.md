# Práctica 9 – Cámara, multimedia y sensores de movimiento

**Autor:** Angel Andrei Leon Aguilar
**Matrícula:** 8950
**Rama:** `practica-09-multimedia-sensores`

App en Flutter para llevar una **bitácora de inspección**. Toma fotografías con la cámara del dispositivo, lee en tiempo real el acelerómetro y el giroscopio, y guarda cada foto en una tarjeta de evidencia con su fecha y hora y los valores de los sensores al momento de la captura.

## Objetivo

Integrar la captura de imágenes y la lectura de sensores para que la app interactúe con el hardware del dispositivo.

## Funcionalidades

### 1. Ejemplo guiado: cámara y sensores

- Toma una fotografía con `image_picker` y la muestra en pantalla.
- Muestra en tiempo real los ejes X, Y y Z del acelerómetro.
- **Ampliación:** también muestra los ejes X, Y y Z del giroscopio.

### 2. Bitácora de inspección (ejercicio evaluable)

- Panel **"Lectura en vivo"** con el acelerómetro (m/s²) y el giroscopio (rad/s).
- Botón **"Nueva evidencia"** que abre la cámara.
- Cada captura crea una **tarjeta de evidencia** con:
  - la fotografía,
  - la fecha y hora (`dd/MM/yyyy HH:mm:ss`),
  - los valores del acelerómetro y del giroscopio en ese momento.
- Los valores de cada tarjeta quedan fijos aunque los sensores sigan cambiando.
- Las tarjetas se numeran y la más reciente aparece primero.

### 3. Manejo de errores

| Situación | Comportamiento |
|---|---|
| El usuario cancela la cámara | Aviso "Captura cancelada por el usuario". No se crea tarjeta y la app sigue funcionando |
| Permiso de cámara denegado | Aviso en rojo que pide habilitar el permiso en Ajustes |
| Error al abrir la cámara | Aviso con la descripción del error |
| El dispositivo no tiene alguno de los sensores | La bitácora muestra "No disponible en este dispositivo" |
| Se pulsa el botón varias veces seguidas | El botón se desactiva mientras la cámara está abierta |

### 4. Lectura de sensores sin bloquear la interfaz

- Los streams usan `SensorInterval.uiInterval` (unos 60 Hz), suficiente para la pantalla.
- En la bitácora, los valores en vivo se guardan en `ValueNotifier` y se muestran con `ValueListenableBuilder`. Así solo se redibuja el panel en vivo y no la lista de tarjetas.
- Las suscripciones a los sensores se cancelan en `dispose()`.

## Tecnologías

- Flutter 3.47 / Dart 3.13
- [`image_picker`](https://pub.dev/packages/image_picker): captura de fotos con la cámara
- [`sensors_plus`](https://pub.dev/packages/sensors_plus): acelerómetro y giroscopio
- [`intl`](https://pub.dev/packages/intl): formato de fecha y hora

## Requisitos

- Flutter 3.x
- Android Studio o Xcode
- Un teléfono con cámara, acelerómetro y giroscopio, o un emulador con cámara y sensores virtuales

## Instalación

```bash
git clone <url-del-repositorio>
cd <carpeta-del-proyecto>
git checkout practica-09-multimedia-sensores
flutter pub get
```

## Ejecución

```bash
flutter run
```

En el emulador de Android, los valores de los sensores se cambian en *Extended controls → Virtual sensors*. La cámara usa la escena virtual del emulador.

## Permisos

| Plataforma | Archivo | Configuración |
|---|---|---|
| Android | `android/app/src/main/AndroidManifest.xml` | `uses-feature` de `camera`, `sensor.accelerometer` y `sensor.gyroscope` con `required="false"`, para que la app se pueda instalar aunque falte alguno. `image_picker` abre la cámara del sistema mediante un intent, por lo que no se pide el permiso `CAMERA` en tiempo de ejecución |
| iOS | `ios/Runner/Info.plist` | `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` y `NSMotionUsageDescription` |

## Estructura del proyecto

```
lib/
  main.dart                          Pantalla de inicio y navegación
  models/registro_inspeccion.dart    Lectura de tres ejes y registro de la bitácora
  services/camara_service.dart       Captura de foto, cancelación y permisos
  services/sensores_service.dart     Streams del acelerómetro y del giroscopio
  pages/sensores_page.dart           Ejemplo guiado
  pages/bitacora_page.dart           Bitácora de inspección
  widgets/tarjeta_evidencia.dart     Tarjeta con foto, fecha/hora y sensores
test/widget_test.dart                Pruebas unitarias y de widgets
docs/evidencias/practica-09/         Capturas de pantalla y resultados de pruebas
```

## Pruebas

```bash
dart format .
flutter analyze
flutter test
```

Resultado actual: `flutter analyze` sin problemas y **8 pruebas aprobadas**.

| Grupo | Prueba |
|---|---|
| `capturarFoto` | Devuelve "cancelada" cuando el usuario cierra la cámara |
| `capturarFoto` | Detecta el permiso denegado |
| `capturarFoto` | Devuelve la foto cuando la captura es correcta |
| `BitacoraPage` | Muestra las lecturas en vivo del acelerómetro y del giroscopio |
| `BitacoraPage` | Crea una tarjeta con la fecha y los valores congelados |
| `BitacoraPage` | Maneja la cancelación de la cámara |
| `BitacoraPage` | Informa cuando falta el permiso de cámara |
| `BitacoraPage` | Indica "sensor no disponible" si el stream falla |

La cámara y los sensores se pasan a las pantallas como parámetros, por lo que las pruebas usan datos simulados y no necesitan un dispositivo real.

## Evidencias

Las capturas y las pruebas manuales están en [`docs/evidencias/practica-09/pruebas.md`](docs/evidencias/practica-09/pruebas.md).

| Captura | Contenido |
|---|---|
| [`01_inicio.png`](docs/evidencias/practica-09/01_inicio.png) | Pantalla de inicio |
| [`02_ejemplo_guiado.png`](docs/evidencias/practica-09/02_ejemplo_guiado.png) | Foto y lecturas en el ejemplo guiado |
| [`03_bitacora_vivo.png`](docs/evidencias/practica-09/03_bitacora_vivo.png) | Bitácora con el panel de lectura en vivo |
| [`04_cancelacion.png`](docs/evidencias/practica-09/04_cancelacion.png) | Aviso al cancelar la cámara |
| [`05_tarjetas_evidencia.png`](docs/evidencias/practica-09/05_tarjetas_evidencia.png) | Dos tarjetas de evidencia |
| [`06_valores_congelados.png`](docs/evidencias/practica-09/06_valores_congelados.png) | Las tarjetas conservan sus valores después de mover los sensores |

## Limitaciones conocidas

- Las evidencias se guardan solo en memoria: se pierden al salir de la bitácora o cerrar la app.
- La fecha, la hora y los valores de los sensores se toman al regresar de la cámara, no en el instante exacto en que se dispara la foto.
- El ejemplo guiado no avisa cuando falta un sensor; en ese caso muestra 0.00. La bitácora sí lo indica.

## Vinculación con el proyecto integrador

La captura de fotos y la lectura de sensores están separadas en `camara_service.dart` y `sensores_service.dart`, así que se pueden reutilizar en el proyecto integrador. Por ejemplo, para adjuntar fotografías de evidencia a un registro o para guardar la orientación del dispositivo en el momento de una captura.

## Autor

| Nombre | Matrícula |
|---|---|
| Angel Andrei Leon Aguilar | 8950 |
