import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/buttons.dart';
import '../../core/database/database_provider.dart';
import '../../core/utils/printer_service.dart';
import 'providers/sales_provider.dart';
import '../settings/providers/settings_provider.dart';

class SalesScreen extends ConsumerWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  'Historique des Ventes',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SecondaryButton(
                  text: 'Exporter (CSV)',
                  icon: Icons.download,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                child: Column(
                  children: [
                    _buildToolbar(),
                    const Divider(height: 1),
                    Expanded(
                      child: _buildSalesTable(ref),
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

  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher par N° Facture',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 16),
          SecondaryButton(
            text: 'Filtrer par date',
            icon: Icons.calendar_today,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSalesTable(WidgetRef ref) {
    final currency = ref.watch(settingsProvider).currency;
    final salesAsync = ref.watch(salesHistoryProvider);

    return salesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Erreur: $err')),
      data: (sales) {
        if (sales.isEmpty) {
          return const Center(child: Text('Aucune vente enregistrée.'));
        }

        return ListView(
          children: [
            DataTable(
              headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              columns: const [
                DataColumn(label: Text('N° Facture')),
                DataColumn(label: Text('Date & Heure')),
                DataColumn(label: Text('Total')),
                DataColumn(label: Text('Paiement')),
                DataColumn(label: Text('Actions')),
              ],
              rows: sales.map((sale) {
                final d = sale.date;
                final dateStr = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
                
                return DataRow(
                  cells: [
                    DataCell(Text(sale.saleNumber, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(dateStr)),
                    DataCell(Text('${sale.total} $currency', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold))),
                    DataCell(_buildPaymentBadge(sale.paymentMethod)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility, size: 20, color: Colors.blue), 
                            tooltip: 'Voir détails',
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.print, size: 20, color: Colors.grey), 
                            tooltip: 'Imprimer ticket',
                            onPressed: () async {
                              final db = ref.read(databaseProvider);
                              final items = await (db.select(db.saleItems)..where((i) => i.saleId.equals(sale.id))).get();
                              
                              final productIds = items.map((i) => i.productId).toList();
                              final products = await (db.select(db.products)..where((p) => p.id.isIn(productIds))).get();
                              
                              final settings = ref.read(settingsProvider);
                              await PrinterService.printReceipt(sale, items, products, settings.currency, settings.storeName, settings.receiptFooter);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentBadge(String method) {
    Color color;
    switch (method.toUpperCase()) {
      case 'MOBILE MONEY':
        color = Colors.orange;
        break;
      case 'CARTE':
        color = Colors.purple;
        break;
      case 'CRÉDIT':
        color = Colors.red;
        break;
      default:
        color = AppTheme.successColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        method,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
