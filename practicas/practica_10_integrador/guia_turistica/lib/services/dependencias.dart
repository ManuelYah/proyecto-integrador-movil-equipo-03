import 'package:flutter/widgets.dart';

import 'clima_service.dart';
import 'lugar_repository.dart';
import 'notificaciones.dart';
import 'ubicacion_service.dart';

/// Contenedor de servicios inyectable (permite dobles en pruebas).
class Dependencias {
  final LugarRepository repositorio;
  final ClimaService clima;
  final UbicacionService ubicacion;
  final Notificaciones notificaciones;

  Dependencias({
    LugarRepository? repositorio,
    ClimaService? clima,
    UbicacionService? ubicacion,
    Notificaciones? notificaciones,
  }) : repositorio = repositorio ?? LugarRepository(),
       clima = clima ?? ClimaService(),
       ubicacion = ubicacion ?? UbicacionService(),
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
  bool updateShouldNotify(DependenciasScope old) =>
      dependencias != old.dependencias;
}
