import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/pos/providers/session_provider.dart';
import '../../features/settings/providers/settings_provider.dart';
import '../../features/pos/widgets/closing_balance_panel.dart';
import 'right_side_panel.dart';

class AppSidebar extends ConsumerWidget {
  final String currentRoute;
  
  const AppSidebar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 250,
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          _buildLogo(context, ref),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildNavItem(context, 'Tableau de bord', Icons.dashboard_outlined, '/'),
                _buildNavItem(context, 'Caisse (POS)', Icons.point_of_sale_outlined, '/pos'),
                _buildNavItem(context, 'Produits', Icons.inventory_2_outlined, '/products'),
                _buildNavItem(context, 'Ventes', Icons.receipt_long_outlined, '/sales'),
                _buildNavItem(context, 'Clients', Icons.people_outline, '/customers'),
                _buildNavItem(context, 'Rapports', Icons.bar_chart_outlined, '/reports'),
                _buildNavItem(context, 'Paramètres', Icons.settings_outlined, '/settings'),
              ],
            ),
          ),
          const Divider(),
          _buildStatus(context, ref),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context, WidgetRef ref) {
    final storeName = ref.watch(settingsProvider).storeName;
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Image.asset('assets/images/logo.png', width: 40, height: 40, errorBuilder: (context, error, stackTrace) => const Icon(Icons.storefront, size: 40)),
          const SizedBox(width: 12),
          Text(
            storeName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, IconData icon, String route) {
    final isSelected = currentRoute == route;
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return ListTile(
      leading: Icon(icon, color: isSelected ? primaryColor : Colors.grey[600]),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? primaryColor : Colors.grey[800],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: primaryColor.withOpacity(0.1),
      onTap: () {
        if (!isSelected) {
          context.go(route);
        }
      },
    );
  }

  Widget _buildStatus(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(activeSessionProvider);
    final isOpen = sessionAsync.valueOrNull != null;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text('● Hors ligne', style: TextStyle(color: Colors.grey)),
            ],
          ),
          if (isOpen)
            IconButton(
              icon: const Icon(Icons.lock, color: Colors.redAccent),
              tooltip: 'Clôturer la caisse',
              onPressed: () {
                showRightSidePanel(
                  context: context,
                  builder: (context) => const ClosingBalancePanel(),
                );
              },
            ),
        ],
      ),
    );
  }
}
