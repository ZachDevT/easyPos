import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/theme/app_theme.dart';
import 'providers/dashboard_provider.dart';
import '../../features/settings/providers/settings_provider.dart';
import '../../features/reports/providers/reports_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(settingsProvider).currency;
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
                    final crossAxisCount = constraints.maxWidth > 1000 ? 3 : constraints.maxWidth > 600 ? 2 : 1;
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
                          value: '${stats.totalSales} $currency',
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
                          ref.watch(reportsProvider).when(
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (e, st) => const Center(child: Text('Erreur de chargement')),
                            data: (data) {
                              if (data.dailyRevenue.isEmpty) return const Center(child: Text('Aucune donnée.'));
                              List<FlSpot> spots = [];
                              for (int i = 0; i < data.dailyRevenue.length; i++) {
                                spots.add(FlSpot(i.toDouble(), data.dailyRevenue[i].revenue));
                              }
                              return Container(
                                height: 200,
                                padding: const EdgeInsets.only(top: 16),
                                child: LineChart(
                                  LineChartData(
                                    gridData: const FlGridData(show: false),
                                    titlesData: const FlTitlesData(
                                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: spots,
                                        isCurved: true,
                                        color: AppTheme.primaryColor,
                                        barWidth: 3,
                                        belowBarData: BarAreaData(show: true, color: AppTheme.primaryColor.withOpacity(0.1)),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
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
                          statsAsync.when(
                            loading: () => const CircularProgressIndicator(),
                            error: (_, __) => const SizedBox(),
                            data: (stats) {
                              if (stats.lowStockItems.isEmpty) {
                                return const Text('Aucun stock faible.', style: TextStyle(color: Colors.green));
                              }
                              return Column(
                                children: stats.lowStockItems.take(5).map((p) => _buildLowStockItem(p.name, '${p.stockQuantity} ${p.unit}')).toList(),
                              );
                            }
                          ),
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
