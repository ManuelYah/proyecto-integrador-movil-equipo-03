import 'package:flutter/material.dart';

import 'pages/bitacora_page.dart';
import 'pages/sensores_page.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Práctica 9 - Multimedia y sensores',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
    home: const InicioPage(),
  );
}

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Práctica 9')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.sensors),
            title: const Text('Ejemplo guiado'),
            subtitle: const Text('Cámara, acelerómetro y giroscopio'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SensoresPage()),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Bitácora de inspección'),
            subtitle: const Text('Ejercicio evaluable'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BitacoraPage()),
            ),
          ),
        ),
      ],
    ),
  );
}
