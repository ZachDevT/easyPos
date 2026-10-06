import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/buttons.dart';
import '../../features/settings/providers/settings_provider.dart';
import 'providers/reports_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsProvider);
    final currency = ref.watch(settingsProvider).currency;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rapports & Analyses',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SecondaryButton(
                  text: 'Imprimer Rapport',
                  icon: Icons.print,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: reportsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Erreur: $err')),
                data: (data) => Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Expanded(
                            child: _buildReportCard(
                              'Chiffre d\'affaires sur 30 jours',
                              _buildRevenueChart(data.dailyRevenue, currency),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: _buildReportCard(
                              'Modes de paiement',
                              _buildPaymentPieChart(data.paymentStats, currency),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: _buildReportCard(
                        'Meilleures Ventes (Top 5)',
                        _buildTopProductsList(data.topProducts),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart(List<DailyRevenue> data, String currency) {
    if (data.isEmpty) return const Center(child: Text('Aucune donnée de vente.'));

    List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i].revenue));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
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
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryColor.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentPieChart(List<PaymentStat> data, String currency) {
    if (data.isEmpty) return const Center(child: Text('Aucune donnée de paiement.'));

    List<Color> colors = [
      Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red
    ];

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: data.asMap().entries.map((entry) {
                final idx = entry.key;
                final stat = entry.value;
                return PieChartSectionData(
                  color: colors[idx % colors.length],
                  value: stat.total,
                  title: '',
                  radius: 50,
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final stat = data[index];
              return ListTile(
                leading: Container(width: 16, height: 16, color: colors[index % colors.length]),
                title: Text(stat.method, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${stat.total} $currency'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopProductsList(List<TopProduct> data) {
    if (data.isEmpty) return const Center(child: Text('Aucune vente enregistrée.'));

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final product = data[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: Text('${index + 1}', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
          ),
          title: Text(product.name),
          trailing: Text('${product.totalSold} vendus', style: const TextStyle(fontWeight: FontWeight.bold)),
        );
      },
    );
  }

  Widget _buildReportCard(String title, Widget content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const Divider(),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }
}
