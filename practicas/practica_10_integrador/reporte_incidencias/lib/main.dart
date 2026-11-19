import 'package:flutter/material.dart';

import 'screens/inicio_screen.dart';
import 'services/dependencias.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencias = Dependencias();
  try {
    await dependencias.notificaciones.iniciar();
  } catch (e) {
    debugPrint('Notificaciones no disponibles: $e');
  }
  runApp(ReporteApp(dependencias: dependencias));
}

class ReporteApp extends StatelessWidget {
  final Dependencias dependencias;
  const ReporteApp({super.key, required this.dependencias});

  @override
  Widget build(BuildContext context) {
    return DependenciasScope(
      dependencias: dependencias,
      child: MaterialApp(
        title: 'Reporte Móvil de Incidencias',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFFC2185B),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: const Color(0xFFC2185B),
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        home: const InicioScreen(),
      ),
    );
  }
}
