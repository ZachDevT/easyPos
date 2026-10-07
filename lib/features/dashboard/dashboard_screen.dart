import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_theme.dart';
import '../sales/providers/sales_provider.dart';
import '../products/providers/product_provider.dart';
import '../settings/providers/settings_provider.dart';
import '../reports/providers/reports_provider.dart';

class DashboardStats {
  final double totalSales;
  final int transactionCount;
  final int stockCount;
  final List<dynamic> lowStockItems;

  DashboardStats(this.totalSales, this.transactionCount, this.stockCount, this.lowStockItems);
}

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final sales = await ref.watch(salesHistoryProvider.future);
  final products = await ref.watch(productsStreamProvider.future);
  
  final today = DateTime.now();
  final todaySales = sales.where((s) => s.date.year == today.year && s.date.month == today.month && s.date.day == today.day).toList();
  final totalSales = todaySales.fold(0.0, (sum, s) => sum + s.total);
  
  final lowStock = products.where((p) => p.stockQuantity <= p.minimumStock).toList();
  
  return DashboardStats(totalSales, todaySales.length, products.length, lowStock);
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(settingsProvider).currency;
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour 👋',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Voici ce qui se passe dans votre entreprise aujourd\'hui.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.mutedTextColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),
            
            // Pro Stat Cards (Inspired by EasyHR)
            statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Erreur: $e')),
              data: (stats) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 800;
                    return Flex(
                      direction: isDesktop ? Axis.horizontal : Axis.vertical,
                      children: [
                        Expanded(
                          flex: isDesktop ? 1 : 0,
                          child: _buildProCard(
                            context,
                            title: 'CORE SALES',
                            headline: 'One trusted home for all your transactions.',
                            description: 'Track daily revenue, analyze payment methods, and monitor store performance—accurate, secure and always in context.',
                            amount: '${stats.totalSales.toStringAsFixed(0)} $currency',
                            subtext: '${stats.transactionCount} transactions aujourd\'hui',
                            backgroundColor: AppTheme.pastelPurple,
                            icon: HugeIcons.strokeRoundedWallet01,
                            features: ['Daily tracking', 'Detailed reports', 'Multiple payments'],
                          ),
                        ),
                        if (isDesktop) const SizedBox(width: 24),
                        if (!isDesktop) const SizedBox(height: 24),
                        Expanded(
                          flex: isDesktop ? 1 : 0,
                          child: _buildProCard(
                            context,
                            title: 'INVENTORY & STOCK',
                            headline: 'Products move. Balances stay right.',
                            description: 'Manage your catalog, receive alerts for low stock, and keep your inventory up-to-date through one transparent workflow.',
                            amount: '${stats.stockCount} Produits',
                            subtext: '${stats.lowStockItems.length} articles en stock faible',
                            backgroundColor: AppTheme.pastelOrange,
                            icon: HugeIcons.strokeRoundedPackage,
                            features: ['Low stock alerts', 'Live balances', 'SKU tracking'],
                          ),
                        ),
                      ],
                    );
                  }
                );
              },
            ),

            const SizedBox(height: 40),

            // Main Content Area
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.pastelGreen,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const HugeIcon(
                                icon: HugeIcons.strokeRoundedAnalytics01,
                                color: AppTheme.successColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Évolution des ventes',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        ref.watch(reportsProvider).when(
                          loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                          error: (e, st) => const SizedBox(height: 200, child: Center(child: Text('Erreur de chargement'))),
                          data: (data) {
                            if (data.dailyRevenue.isEmpty) return const SizedBox(height: 200, child: Center(child: Text('Aucune donnée.')));
                            List<FlSpot> spots = [];
                            for (int i = 0; i < data.dailyRevenue.length; i++) {
                              spots.add(FlSpot(i.toDouble(), data.dailyRevenue[i].revenue));
                            }
                            return SizedBox(
                              height: 250,
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
                                      barWidth: 4,
                                      isStrokeCapRound: true,
                                      dotData: const FlDotData(show: false),
                                      belowBarData: BarAreaData(
                                        show: true, 
                                        color: AppTheme.primaryColor.withOpacity(0.1),
                                      ),
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
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.pastelPink,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const HugeIcon(
                                icon: HugeIcons.strokeRoundedAlert01,
                                color: AppTheme.primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Stock faible',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        statsAsync.when(
                          loading: () => const CircularProgressIndicator(),
                          error: (_, __) => const SizedBox(),
                          data: (stats) {
                            if (stats.lowStockItems.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.pastelGreen,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Row(
                                  children: [
                                    HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkBadge01, color: AppTheme.successColor),
                                    SizedBox(width: 12),
                                    Text('Stock en bonne santé', style: TextStyle(color: AppTheme.successColor, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              );
                            }
                            return Column(
                              children: stats.lowStockItems.take(5).map((p) => _buildLowStockItem(p.name, '${p.stockQuantity} ${p.unit}')).toList(),
                            );
                          }
                        ),
                      ],
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

  Widget _buildProCard(BuildContext context, {
    required String title,
    required String headline,
    required String description,
    required String amount,
    required String subtext,
    required Color backgroundColor,
    required List<List<dynamic>> icon,
    required List<String> features,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: HugeIcon(
                  icon: icon,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.mutedTextColor,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            headline,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppTheme.textColor,
              height: 1.1,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.mutedTextColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: features.map((f) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkBadge01, color: AppTheme.textColor, size: 16),
                const SizedBox(width: 6),
                Text(f, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textColor)),
              ],
            )).toList(),
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        amount,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textColor,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtext,
                        style: const TextStyle(color: AppTheme.mutedTextColor, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Text('Explorer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      SizedBox(width: 8),
                      HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: Colors.white, size: 16),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLowStockItem(String name, String quantity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: HugeIcon(icon: HugeIcons.strokeRoundedPackage, size: 20, color: AppTheme.mutedTextColor),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.pastelPink,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(quantity, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryColor, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
