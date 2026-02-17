import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowConfig {
  static Future<void> initialize() async {
    debugPrint(
      '[WINDOW] Initialize called, Platform.isWindows = ${Platform.isWindows}',
    );
    if (!Platform.isWindows) return;

    try {
      debugPrint('[WINDOW] Calling ensureInitialized...');
      await windowManager.ensureInitialized();
      debugPrint('[WINDOW] ensureInitialized completed');

      const windowOptions = WindowOptions(
        size: Size(1280, 720),
        center: true,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden,
      );

      debugPrint('[WINDOW] Configuring window...');
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        debugPrint('[WINDOW] Ready to show, showing window...');
        await windowManager.show();
        await windowManager.focus();
        debugPrint('[WINDOW] Window shown and focused');

        await _setupBorderlessWindow();
        debugPrint('[WINDOW] Borderless setup completed');
      });
    } catch (e) {
      debugPrint('[WINDOW] Initialization error: $e');
    }
  }

  static Future<void> _setupBorderlessWindow() async {
    // Window manager handles the borderless aspect through TitleBarStyle.hidden
    // The actual borderless effect is enforced in the runner configuration
    try {
      await windowManager.setAsFrameless();
    } catch (e) {
      // Fallback: title bar style is already set to hidden
      debugPrint('Could not set frameless mode: $e');
    }
  }
}
