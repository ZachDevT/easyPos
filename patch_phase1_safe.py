import os
import re

with open('lib/features/dashboard/dashboard_screen.dart', 'r') as f:
    content = f.read()

# Add imports
if "import 'package:fl_chart/fl_chart.dart';" not in content:
    content = content.replace(
        "import '../../features/settings/providers/settings_provider.dart';", 
        "import '../../features/settings/providers/settings_provider.dart';\nimport 'package:fl_chart/fl_chart.dart';\nimport '../../features/reports/providers/reports_provider.dart';"
    )

# Remove profit card properly (lines 63-68)
content = re.sub(r'StatCard\([\s\S]*?Bénéfice estimé[\s\S]*?color: AppTheme\.warningColor,\n\s*\),', '', content)
content = content.replace("final crossAxisCount = constraints.maxWidth > 1000 ? 4 : constraints.maxWidth > 600 ? 2 : 1;", "final crossAxisCount = constraints.maxWidth > 1000 ? 3 : constraints.maxWidth > 600 ? 2 : 1;")

# Dashboard evolution chart
chart_ui = '''
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
'''
content = re.sub(r'Container\([\s\S]*?Graphique des ventes[^<]*?Container\),', chart_ui, content)

# Dashboard low stock
low_stock_ui = '''
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
'''
content = re.sub(r'_buildLowStockItem[\s\S]*?T-shirt XL[^;]*\),', low_stock_ui, content)

with open('lib/features/dashboard/dashboard_screen.dart', 'w') as f:
    f.write(content)

# Fix horizontal scrolling on tables
def make_horizontal(file, var_name):
    with open(file, 'r') as f:
        c = f.read()
    
    # Simple replace
    c = c.replace(
        "DataTable(", 
        "SingleChildScrollView(\n              scrollDirection: Axis.horizontal,\n              child: DataTable("
    )
    
    # The end of the DataTable usually looks like:
    # }).toList(),
    #             ),
    # Let's use regex to find the end of DataTable and append `)`
    c = re.sub(r'(rows: [\s\S]*?\.toList\(\),\n\s*\)),', r'\1,),', c)
    
    with open(file, 'w') as f:
        f.write(c)

make_horizontal('lib/features/customers/customers_screen.dart', 'c')
make_horizontal('lib/features/products/products_screen.dart', 'p')

print("Done phase1_dashboard")
