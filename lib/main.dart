import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/game_screen.dart';

void main() {
  runApp(const ProviderScope(child: MagnetClashApp()));
}

class MagnetClashApp extends StatelessWidget {
  const MagnetClashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magnet Clash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4FC3F7),
          secondary: Color(0xFFEF9A9A),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
      ),
      home: const GameScreen(),
    );
  }
}
