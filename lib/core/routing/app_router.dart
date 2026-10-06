import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_layout.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/pos/pos_screen.dart';
import '../../features/products/products_screen.dart';
import '../../features/sales/sales_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/customers/customers_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/auth/auth_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final boutiqueId = prefs.getString('boutique_id');
    final isAuthRoute = state.matchedLocation == '/auth';

    if (boutiqueId == null && !isAuthRoute) {
      return '/auth';
    }
    if (boutiqueId != null && isAuthRoute) {
      return '/';
    }
    return null;
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/auth',
      builder: (BuildContext context, GoRouterState state) {
        return const AuthScreen();
      },
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return AppLayout(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/pos',
          builder: (BuildContext context, GoRouterState state) => const PosScreen(),
        ),
        GoRoute(
          path: '/products',
          builder: (BuildContext context, GoRouterState state) => const ProductsScreen(),
        ),
        GoRoute(
          path: '/sales',
          builder: (BuildContext context, GoRouterState state) => const SalesScreen(),
        ),
        GoRoute(
          path: '/reports',
          builder: (BuildContext context, GoRouterState state) => const ReportsScreen(),
        ),
        GoRoute(
          path: '/customers',
          builder: (BuildContext context, GoRouterState state) => const CustomersScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (BuildContext context, GoRouterState state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);
