import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:metadata_god/metadata_god.dart';
import 'core/theme/app_theme.dart';
import 'core/window/window_config.dart';
import 'features/navigation/providers/nav_provider.dart';
import 'features/player/providers/player_provider.dart';
import 'features/library/providers/library_provider.dart';
import 'features/app/pages/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowConfig.initialize();
  await MetadataGod.initialize();
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
      ],
      child: MaterialApp(
        title: '0rhx Player',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const AppShell(),
      ),
    );
  }
}
