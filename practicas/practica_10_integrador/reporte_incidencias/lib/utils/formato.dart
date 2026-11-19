import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatoFecha(DateTime fecha) =>
    DateFormat('dd/MM/yyyy HH:mm').format(fecha);

String formatoCoordenadas(double? lat, double? lng) =>
    (lat == null || lng == null)
    ? 'Sin ubicación'
    : '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';

IconData iconoCategoria(String categoria) => switch (categoria) {
  'Alumbrado' => Icons.lightbulb_outline,
  'Baches' => Icons.add_road,
  'Basura' => Icons.delete_outline,
  'Agua y drenaje' => Icons.water_drop_outlined,
  'Seguridad' => Icons.shield_outlined,
  _ => Icons.report_outlined,
};
