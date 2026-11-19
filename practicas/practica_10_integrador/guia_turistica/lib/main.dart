import 'package:flutter/material.dart';

import 'screens/inicio_screen.dart';
import 'services/dependencias.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final deps = Dependencias();
  try {
    await deps.notificaciones.iniciar();
  } catch (e) {
    debugPrint('Notificaciones no disponibles: $e');
  }
  runApp(GuiaApp(dependencias: deps));
}

class GuiaApp extends StatelessWidget {
  final Dependencias dependencias;
  const GuiaApp({super.key, required this.dependencias});

  @override
  Widget build(BuildContext context) {
    const semilla = Color(0xFF00796B);
    return DependenciasScope(
      dependencias: dependencias,
      child: MaterialApp(
        title: 'Guía Turística',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: semilla, useMaterial3: true),
        darkTheme: ThemeData(
          colorSchemeSeed: semilla,
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        home: const InicioScreen(),
      ),
    );
  }
}
