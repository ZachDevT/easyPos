import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/buttons.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Expanded(
                          child: _buildReportCard(
                            'Chiffre d\'affaires sur 30 jours',
                            const Center(child: Text('Graphique d\'évolution des ventes (fl_chart)')),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _buildReportCard(
                            'Modes de paiement',
                            const Center(child: Text('Graphique circulaire des paiements')),
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
                      ListView(
                        children: const [
                          ListTile(
                            leading: CircleAvatar(child: Text('1')),
                            title: Text('Coca-Cola 50cl'),
                            trailing: Text('145 vendus', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          ListTile(
                            leading: CircleAvatar(child: Text('2')),
                            title: Text('Savon Lux'),
                            trailing: Text('89 vendus', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          ListTile(
                            leading: CircleAvatar(child: Text('3')),
                            title: Text('Eau Minérale'),
                            trailing: Text('76 vendus', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          ListTile(
                            leading: CircleAvatar(child: Text('4')),
                            title: Text('Pain'),
                            trailing: Text('54 vendus', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          ListTile(
                            leading: CircleAvatar(child: Text('5')),
                            title: Text('Paracétamol'),
                            trailing: Text('22 vendus', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
