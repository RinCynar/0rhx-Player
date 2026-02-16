import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowConfig {
  static Future<void> initialize() async {
    if (Platform.isWindows) {
      await windowManager.ensureInitialized();

      const windowOptions = WindowOptions(
        size: Size(1280, 720),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden,
      );

      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
        // Remove window frame for borderless effect
        await _setupBorderlessWindow();
      });
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
