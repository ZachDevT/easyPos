import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/theme/app_theme.dart';
import 'providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour 👋',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Voici ce qui se passe dans votre entreprise aujourd\'hui.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600]
              ),
            ),
            const SizedBox(height: 24),
            
            // Dashboard Stat Cards
            statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Erreur: $e')),
              data: (stats) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 1000 ? 4 : constraints.maxWidth > 600 ? 2 : 1;
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2.5,
                      children: [
                        StatCard(
                          title: 'Ventes aujourd\'hui',
                          value: '${stats.totalSales} CDF',
                          icon: Icons.payments_outlined,
                          color: AppTheme.primaryColor,
                        ),
                        StatCard(
                          title: 'Transactions',
                          value: '${stats.transactionCount}',
                          icon: Icons.receipt_long_outlined,
                          color: AppTheme.successColor,
                        ),
                        StatCard(
                          title: 'Bénéfice estimé',
                          value: '${stats.estimatedProfit} CDF',
                          icon: Icons.trending_up,
                          color: AppTheme.warningColor,
                        ),
                        StatCard(
                          title: 'Produits en stock',
                          value: '${stats.stockCount}',
                          icon: Icons.inventory_2_outlined,
                          color: Colors.purple,
                        ),
                      ],
                    );
                  }
                );
              },
            ),

            const SizedBox(height: 32),

            // Main Content Area (Split)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Évolution des ventes',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 200,
                            color: Colors.grey[100],
                            alignment: Alignment.center,
                            child: const Text('Graphique des ventes (À implémenter)'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '⚠️ Stock faible',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.dangerColor
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildLowStockItem('Paracétamol', '4 unités'),
                          _buildLowStockItem('Savon Lux', '6 unités'),
                          _buildLowStockItem('T-shirt XL', '2 unités'),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {},
                              child: const Text('Voir le stock'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockItem(String name, String quantity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name),
          Text(quantity, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
