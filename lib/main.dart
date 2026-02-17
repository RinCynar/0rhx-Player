import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/window/window_config.dart';
import 'features/navigation/providers/nav_provider.dart';
import 'features/player/providers/player_provider.dart';
import 'features/library/providers/library_provider.dart';
import 'features/theme/providers/theme_provider.dart';
import 'features/app/pages/app_shell.dart';

void main() async {
  debugPrint('[MAIN] Application starting...');
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[MAIN] WidgetsFlutterBinding initialized');

  // Initialize window manager and await it
  debugPrint('[MAIN] Initializing window manager...');
  await WindowConfig.initialize();

  debugPrint('[MAIN] Running app...');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: '0rhx Player',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}
