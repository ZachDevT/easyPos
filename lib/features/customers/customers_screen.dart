import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/right_side_panel.dart';
import '../../core/database/database_provider.dart';
import 'widgets/add_customer_panel.dart';
import 'providers/customer_provider.dart';

class CustomersScreen extends ConsumerWidget {
  const CustomersScreen({super.key});

  void _showAddCustomer(BuildContext context) {
    showRightSidePanel(
      context: context,
      builder: (context) => const AddCustomerPanel(),
    );
  }

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
                  'Clients',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                PrimaryButton(
                  text: 'Ajouter un client',
                  icon: Icons.person_add,
                  onPressed: () => _showAddCustomer(context),
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
                      child: _buildCustomersTable(ref),
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
                hintText: 'Rechercher un client...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomersTable(WidgetRef ref) {
    final customersAsync = ref.watch(customersStreamProvider);

    return customersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Erreur: $e')),
      data: (customers) {
        if (customers.isEmpty) {
          return const Center(child: Text('Aucun client enregistré.'));
        }

        return ListView(
          children: [
            DataTable(
              headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              columns: const [
                DataColumn(label: Text('Nom')),
                DataColumn(label: Text('Téléphone')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Crédit Dû')),
                DataColumn(label: Text('Actions')),
              ],
              rows: customers.map((c) {
                return DataRow(
                  cells: [
                    DataCell(Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(c.phone ?? '-')),
                    DataCell(Text(c.email ?? '-')),
                    DataCell(Text('${c.totalCredit} CDF', style: TextStyle(color: c.totalCredit > 0 ? AppTheme.dangerColor : AppTheme.successColor, fontWeight: FontWeight.bold))),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility, size: 20, color: Colors.blue),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                            onPressed: () async {
                              final db = ref.read(databaseProvider);
                              await (db.delete(db.customers)..where((tbl) => tbl.id.equals(c.id))).go();
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
}
