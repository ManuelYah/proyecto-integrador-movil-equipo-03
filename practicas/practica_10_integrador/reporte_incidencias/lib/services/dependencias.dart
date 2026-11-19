import 'package:flutter/widgets.dart';

import 'api_service.dart';
import 'foto_service.dart';
import 'notificaciones.dart';
import 'reporte_repository.dart';
import 'ubicacion_service.dart';

/// Contenedor de servicios. Permite sustituirlos por dobles en las pruebas.
class Dependencias {
  final ReporteRepository repositorio;
  final ApiService api;
  final UbicacionService ubicacion;
  final FotoService foto;
  final Notificaciones notificaciones;

  Dependencias({
    ReporteRepository? repositorio,
    ApiService? api,
    UbicacionService? ubicacion,
    FotoService? foto,
    Notificaciones? notificaciones,
  }) : repositorio = repositorio ?? ReporteRepository(),
       api = api ?? ApiService(),
       ubicacion = ubicacion ?? UbicacionService(),
       foto = foto ?? FotoService(),
       notificaciones = notificaciones ?? Notificaciones();

  static Dependencias of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<DependenciasScope>()!
      .dependencias;
}

class DependenciasScope extends InheritedWidget {
  final Dependencias dependencias;
  const DependenciasScope({
    super.key,
    required this.dependencias,
    required super.child,
  });

  @override
  bool updateShouldNotify(DependenciasScope oldWidget) =>
      dependencias != oldWidget.dependencias;
}
