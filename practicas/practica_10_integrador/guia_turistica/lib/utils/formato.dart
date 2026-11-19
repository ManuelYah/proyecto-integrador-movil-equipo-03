import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatoFecha(DateTime f) => DateFormat('dd/MM/yyyy HH:mm').format(f);

String formatoCoordenadas(double? lat, double? lng) =>
    (lat == null || lng == null)
    ? 'Sin ubicación'
    : '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';

IconData iconoCategoria(String c) => switch (c) {
  'Playa' => Icons.beach_access,
  'Museo' => Icons.museum_outlined,
  'Zona arqueológica' => Icons.account_balance_outlined,
  'Gastronomía' => Icons.restaurant,
  'Naturaleza' => Icons.park_outlined,
  'Centro histórico' => Icons.location_city,
  _ => Icons.place_outlined,
};

IconData iconoClima(int codigo) => switch (codigo) {
  0 => Icons.wb_sunny_outlined,
  1 || 2 || 3 => Icons.cloud_outlined,
  >= 51 && <= 82 => Icons.water_drop_outlined,
  >= 95 => Icons.thunderstorm_outlined,
  _ => Icons.filter_drama_outlined,
};
