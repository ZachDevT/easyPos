import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import '../providers/zoom_provider.dart';

/// A compact, custom window title bar with drag area + traffic-light controls.
/// Matches the Apple-inspired design of the rest of Yellow Pos.
class WindowTitleBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final String title;
  const WindowTitleBar({super.key, this.title = 'Yellow Pos'});

  @override
  Size get preferredSize => const Size.fromHeight(38);

  @override
  ConsumerState<WindowTitleBar> createState() => _WindowTitleBarState();
}

class _WindowTitleBarState extends ConsumerState<WindowTitleBar> with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.addListener(this);
      _checkMaximized();
    }
  }

  @override
  void dispose() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  Future<void> _checkMaximized() async {
    final maximized = await windowManager.isMaximized();
    if (mounted) setState(() => _isMaximized = maximized);
  }

  @override
  void onWindowMaximize() => setState(() => _isMaximized = true);

  @override
  void onWindowUnmaximize() => setState(() => _isMaximized = false);

  @override
  Widget build(BuildContext context) {
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 38,
      color: const Color(0xFF111827),
      child: Row(
        children: [
          // Drag area — takes all space except the buttons
          Expanded(
            child: DragToMoveArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  children: [
                    // App icon
                    Container(
                      width: 18, height: 18,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE91E63), Color(0xFFD946EF)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Text('Y', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Zoom controls
          _WinBtn(
            tooltip: 'Zoom Arrière',
            icon: Icons.zoom_out,
            onPressed: () => ref.read(zoomProvider.notifier).zoomOut(),
          ),
          _WinBtn(
            tooltip: 'Réinitialiser Zoom',
            icon: Icons.center_focus_strong,
            onPressed: () => ref.read(zoomProvider.notifier).reset(),
          ),
          _WinBtn(
            tooltip: 'Zoom Avant',
            icon: Icons.zoom_in,
            onPressed: () => ref.read(zoomProvider.notifier).zoomIn(),
          ),
          const SizedBox(width: 16),
          
          // Window controls
          _WinBtn(
            tooltip: 'Réduire',
            icon: Icons.remove,
            onPressed: () => windowManager.minimize(),
          ),
          _WinBtn(
            tooltip: _isMaximized ? 'Restaurer' : 'Agrandir',
            icon: _isMaximized ? Icons.fullscreen_exit : Icons.fullscreen,
            onPressed: () async {
              if (_isMaximized) {
                await windowManager.unmaximize();
              } else {
                await windowManager.maximize();
              }
            },
          ),
          _WinBtn(
            tooltip: 'Fermer',
            icon: Icons.close,
            onPressed: () => windowManager.close(),
            isClose: true,
          ),
        ],
      ),
    );
  }
}

class _WinBtn extends StatefulWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isClose;
  const _WinBtn({required this.tooltip, required this.icon, required this.onPressed, this.isClose = false});

  @override
  State<_WinBtn> createState() => _WinBtnState();
}

class _WinBtnState extends State<_WinBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    Color hoverBg = widget.isClose ? const Color(0xFFE81123) : const Color(0xFF374151);

    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 600),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 46,
            height: 38,
            color: _hovered ? hoverBg : Colors.transparent,
            child: Icon(
              widget.icon,
              size: 16,
              color: _hovered && widget.isClose ? Colors.white : Colors.white60,
            ),
          ),
        ),
      ),
    );
  }
}

