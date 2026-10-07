import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_sidebar.dart';
import 'window_title_bar.dart';
import '../providers/zoom_provider.dart';

class AppLayout extends ConsumerWidget {
  final Widget child;

  const AppLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    final GoRouterState state = GoRouterState.of(context);
    final String currentRoute = state.uri.toString();
    final isNativeDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    final zoom = ref.watch(zoomProvider);

    return Scaffold(
      body: Column(
        children: [
          if (isNativeDesktop) const WindowTitleBar(),
          Expanded(
            child: Transform.scale(
              scale: zoom,
              alignment: Alignment.topLeft,
              child: Row(
                children: [
                  if (isDesktop) AppSidebar(currentRoute: currentRoute),
                  Expanded(
                    child: Column(
                      children: [
                        if (!isDesktop) AppBar(title: const Text('Yellow Pos')),
                        Expanded(child: child),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: isDesktop ? null : Drawer(child: AppSidebar(currentRoute: currentRoute)),
    );
  }
}

