import 'dart:io';
import 'package:flutter/material.dart';
import 'app_sidebar.dart';
import 'window_title_bar.dart';
import 'package:go_router/go_router.dart';

class AppLayout extends StatelessWidget {
  final Widget child;

  const AppLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    final GoRouterState state = GoRouterState.of(context);
    final String currentRoute = state.uri.toString();
    final isNativeDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    return Scaffold(
      body: Column(
        children: [
          // Custom title bar — only on desktop platforms
          if (isNativeDesktop) const WindowTitleBar(),

          // Main content: sidebar + page
          Expanded(
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
        ],
      ),
      drawer: isDesktop ? null : Drawer(child: AppSidebar(currentRoute: currentRoute)),
    );
  }
}
