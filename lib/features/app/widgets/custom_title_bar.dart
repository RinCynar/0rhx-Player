import 'package:flutter/material.dart';
import 'dart:io';
import 'package:window_manager/window_manager.dart';

class CustomTitleBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  const CustomTitleBar({
    super.key,
    required this.title,
  });

  @override
  State<CustomTitleBar> createState() => _CustomTitleBarState();

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

class _CustomTitleBarState extends State<CustomTitleBar> {
  bool _isMaximized = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // Title bar with window controls
          SizedBox(
            height: 56,
            child: Row(
              children: [
                // App title
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                // Window control buttons
                if (Platform.isWindows) ...[
                  _WindowControlButton(
                    icon: Icons.remove,
                    tooltip: 'Minimize',
                    onPressed: () async {
                      await windowManager.minimize();
                    },
                  ),
                  _WindowControlButton(
                    icon: _isMaximized ? Icons.fullscreen_exit : Icons.fullscreen,
                    tooltip: _isMaximized ? 'Restore' : 'Maximize',
                    onPressed: () async {
                      final isMaximized = await windowManager.isMaximized();
                      if (isMaximized) {
                        await windowManager.unmaximize();
                      } else {
                        await windowManager.maximize();
                      }
                      setState(() {
                        _isMaximized = !_isMaximized;
                      });
                    },
                  ),
                  _WindowControlButton(
                    icon: Icons.close,
                    tooltip: 'Close',
                    onPressed: () async {
                      await windowManager.close();
                    },
                    isCloseButton: true,
                  ),
                ],
              ],
            ),
          ),
          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ],
      ),
    );
  }
}

class _WindowControlButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isCloseButton;

  const _WindowControlButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isCloseButton = false,
  });

  @override
  State<_WindowControlButton> createState() => _WindowControlButtonState();
}

class _WindowControlButtonState extends State<_WindowControlButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 48,
          height: 56,
          color: _isHovered
              ? (widget.isCloseButton ? Colors.red : Colors.grey.withValues(alpha: 0.1))
              : Colors.transparent,
          child: Tooltip(
            message: widget.tooltip,
            child: Icon(
              widget.icon,
              color: widget.isCloseButton && _isHovered ? Colors.white : null,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
