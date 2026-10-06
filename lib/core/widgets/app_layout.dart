import 'package:flutter/material.dart';
import 'app_sidebar.dart';
import 'package:go_router/go_router.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  
  const AppLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Basic responsive layout
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    
    // Get current route safely
    final GoRouterState state = GoRouterState.of(context);
    final String currentRoute = state.uri.toString();

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop) AppSidebar(currentRoute: currentRoute),
          Expanded(
            child: Column(
              children: [
                if (!isDesktop) AppBar(title: const Text('EasyPOS')),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
      drawer: isDesktop ? null : Drawer(child: AppSidebar(currentRoute: currentRoute)),
    );
  }
}
