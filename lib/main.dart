import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
import 'views/main_layout.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: SitaRamApp(),
    ),
  );
}

class SitaRamApp extends StatelessWidget {
  const SitaRamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SitaRam - Valmiki Ramayana',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Defaulting to the beautiful spiritual dark theme
      home: const MainLayout(),
    );
  }
}
