import os
import re

# 1. Update dashboard_provider.dart
with open('lib/features/dashboard/providers/dashboard_provider.dart', 'r') as f:
    content = f.read()

# Add low stock items to DashboardStats
content = content.replace(
'''  DashboardStats({
    required this.totalSales,
    required this.transactionCount,
    required this.estimatedProfit,
    required this.stockCount,
  });''',
'''  final List<Product> lowStockItems;

  DashboardStats({
    required this.totalSales,
    required this.transactionCount,
    required this.estimatedProfit,
    required this.stockCount,
    required this.lowStockItems,
  });'''
)
if "final List<Product> lowStockItems;" not in content:
    content = content.replace("final double stockCount;", "final double stockCount;\n  final List<Product> lowStockItems;")

# Implement low stock logic
low_stock_logic = '''
  final lowStockQuery = db.select(db.products)..where((p) => p.stockQuantity.isSmallerOrEqualExp(p.minimumStock));
  final lowStockItems = await lowStockQuery.get();

  return DashboardStats(
    totalSales: totalSales,
    transactionCount: transactionCount,
    estimatedProfit: estimatedProfit,
    stockCount: stockCount,
    lowStockItems: lowStockItems,
  );
'''
content = re.sub(r'return DashboardStats\([\s\S]*?\);', low_stock_logic, content)

with open('lib/features/dashboard/providers/dashboard_provider.dart', 'w') as f:
    f.write(content)


# 2. Update dashboard_screen.dart
with open('lib/features/dashboard/dashboard_screen.dart', 'r') as f:
    content = f.read()

content = content.replace("import '../../features/settings/providers/settings_provider.dart';", "import '../../features/settings/providers/settings_provider.dart';\nimport 'package:fl_chart/fl_chart.dart';\nimport '../../features/reports/providers/reports_provider.dart';")

# Remove profit card
content = re.sub(r'StatCard\([\s\S]*?Bénéfice estimé[\s\S]*?AppTheme\.warningColor,\n\s*\),', '', content)
content = content.replace("final crossAxisCount = constraints.maxWidth > 1000 ? 4 : constraints.maxWidth > 600 ? 2 : 1;", "final crossAxisCount = constraints.maxWidth > 1000 ? 3 : constraints.maxWidth > 600 ? 2 : 1;")

# Replace "Évolution des ventes" placeholder
reports_async_logic = '''
                          final reportsAsync = ref.watch(reportsProvider);
                          return reportsAsync.when(
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
                                padding: const EdgeInsets.all(16),
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
                          );
'''
content = re.sub(r'Container\([\s\S]*?Graphique des ventes[^<]*?Container>', reports_async_logic, content)

# Replace Low Stock UI
content = re.sub(
    r'_buildLowStockItem\([\s\S]*?Voir le stock[\s\S]*?\),',
    '''
                          statsAsync.when(
                            loading: () => const CircularProgressIndicator(),
                            error: (_, __) => const SizedBox(),
                            data: (stats) {
                              if (stats.lowStockItems.isEmpty) return const Text('Aucun stock faible.', style: TextStyle(color: Colors.green));
                              return Column(
                                children: stats.lowStockItems.map((p) => _buildLowStockItem(p.name, '${p.stockQuantity} ${p.unit}')).toList(),
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
''',
    content
)

with open('lib/features/dashboard/dashboard_screen.dart', 'w') as f:
    f.write(content)


# 3. Tables Scrollable horizontally (Products, Customers, Categories)
def make_scrollable(filepath):
    with open(filepath, 'r') as f:
        c = f.read()
    c = c.replace("DataTable(", "SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(")
    # Need to close the parenthesis
    c = re.sub(r'rows: (.*?)\.toList\(\),\n\s*\),', r'rows: \1.toList(),\n            ),)', c)
    with open(filepath, 'w') as f:
        f.write(c)

make_scrollable('lib/features/customers/customers_screen.dart')
make_scrollable('lib/features/products/products_screen.dart')

# 4. App Sidebar 
with open('lib/core/widgets/app_sidebar.dart', 'r') as f:
    c = f.read()

c = c.replace("width: 280", "width: 220")
new_menu = '''
          _buildMenuItem(Icons.settings, 'Paramètres', '/settings', ref),
          _buildMenuItem(Icons.analytics, 'Analytiques', '/analytics', ref),
'''
c = c.replace("_buildMenuItem(Icons.settings, 'Paramètres', '/settings', ref),", new_menu)

with open('lib/core/widgets/app_sidebar.dart', 'w') as f:
    f.write(c)

print("Phase 1 UI UI patches complete!")
