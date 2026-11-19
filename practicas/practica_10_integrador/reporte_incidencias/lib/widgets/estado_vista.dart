import 'package:flutter/material.dart';

/// Vistas reutilizables para los estados de carga, error y vacío.
class Cargando extends StatelessWidget {
  final String mensaje;
  const Cargando({super.key, this.mensaje = 'Cargando...'});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(mensaje),
      ],
    ),
  );
}

class MensajeEstado extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? detalle;
  final String? textoAccion;
  final VoidCallback? onAccion;
  final bool esError;

  const MensajeEstado({
    super.key,
    required this.icono,
    required this.titulo,
    this.detalle,
    this.textoAccion,
    this.onAccion,
    this.esError = false,
  });

  const MensajeEstado.error({
    super.key,
    required String mensaje,
    required VoidCallback onReintentar,
  }) : icono = Icons.cloud_off,
       titulo = 'Ocurrió un problema',
       detalle = mensaje,
       textoAccion = 'Reintentar',
       onAccion = onReintentar,
       esError = true;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icono,
              size: 64,
              color: esError ? esquema.error : esquema.primary,
            ),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (detalle != null) ...[
              const SizedBox(height: 8),
              Text(detalle!, textAlign: TextAlign.center),
            ],
            if (textoAccion != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: onAccion,
                child: Text(textoAccion!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
