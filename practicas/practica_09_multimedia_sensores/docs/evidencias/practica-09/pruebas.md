# Evidencias – Práctica 9

## flutter analyze

```
Analyzing Practica 9...
No issues found!
```

## flutter test

```
00:00 +1: capturarFoto devuelve cancelada cuando el usuario cierra la cámara
00:00 +2: capturarFoto detecta permiso denegado
00:00 +3: capturarFoto devuelve la foto cuando la captura es correcta
00:00 +4: BitacoraPage muestra lecturas en vivo de acelerómetro y giroscopio
00:01 +5: BitacoraPage crea una tarjeta con fecha y valores congelados
00:01 +6: BitacoraPage maneja la cancelación de la cámara
00:01 +7: BitacoraPage informa cuando falta el permiso de cámara
00:01 +8: BitacoraPage indica sensor no disponible si el stream falla
00:01 +8: All tests passed!
```

## Casos manuales

Dispositivo: emulador Android "Medium Phone" (API 36), con cámara y sensores virtuales. Las lecturas del acelerómetro y el giroscopio se fijaron con *Extended controls → Virtual sensors* (`adb emu sensor set`).

| # | Caso | Resultado | Evidencia |
|---|---|---|---|
| 1 | Abrir la app | Correcto. Menú con "Ejemplo guiado" y "Bitácora de inspección" | `01_inicio.png` |
| 2 | Ejemplo guiado: tomar fotografía | Correcto. La foto se muestra; acelerómetro X 2.50, Y 4.10, Z 8.60; giroscopio X 0.35, Y -0.12, Z 0.08 | `02_ejemplo_guiado.png` |
| 3 | Abrir la bitácora | Correcto. Panel "Lectura en vivo" con acelerómetro 0.12 / 9.78 / 0.45 y giroscopio 0.02 / 0.01 / -0.03; mensaje "Sin evidencias" | `03_bitacora_vivo.png` |
| 4 | Abrir la cámara y cancelar con Atrás | Correcto. Aviso "Captura cancelada por el usuario"; no se crea tarjeta y la app no se cierra | `04_cancelacion.png` |
| 5 | Crear dos evidencias con lecturas distintas | Correcto. Evidencia #1 (08:02:05) y #2 (08:02:27), cada una con su foto y valores | `05_tarjetas_evidencia.png` |
| 6 | Cambiar los sensores después de capturar | Correcto. El panel en vivo cambia a 1.10 / 8.20 / 4.90 y las tarjetas conservan sus valores | `06_valores_congelados.png` |
| 7 | Permiso de cámara denegado | Cubierto con prueba automática. En Android, `image_picker` abre la cámara del sistema mediante un intent y no pide permiso en tiempo de ejecución | – |
| 8 | Dispositivo sin giroscopio | Cubierto con prueba automática. El panel muestra "No disponible en este dispositivo" | – |

## Problema encontrado y solución

La primera ejecución de `flutter analyze` reportó 4 avisos `unnecessary_underscores` por usar `__` y `___` como parámetros sin usar en los `builder` de `ValueListenableBuilder` y en el `errorBuilder` de `Image.file`.

Solución: se reemplazaron por `_`, y `flutter analyze` quedó sin problemas.

## Lectura de sensores sin bloquear la interfaz

El acelerómetro y el giroscopio envían eventos continuamente. Para no redibujar toda la pantalla con cada evento:

- Los streams usan `SensorInterval.uiInterval` (unos 60 Hz).
- En la bitácora los valores en vivo se guardan en `ValueNotifier` y se muestran con `ValueListenableBuilder`, así que solo se redibuja el panel y no la lista de tarjetas.
- Las suscripciones se cancelan en `dispose()`.
