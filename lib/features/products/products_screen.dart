import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/right_side_panel.dart';
import '../../core/widgets/admin_auth_panel.dart';
import '../../core/widgets/admin_setup_panel.dart';
import '../../core/providers/admin_provider.dart';
import '../../core/database/database_provider.dart';
import 'widgets/add_product_panel.dart';
import 'widgets/categories_panel.dart';
import 'providers/product_provider.dart';
import '../settings/providers/settings_provider.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  void _showAddProductPanel(BuildContext context, WidgetRef ref) async {
    final hasPin = ref.read(adminProvider.notifier).hasPin;
    
    if (!hasPin) {
      final setup = await showRightSidePanel<bool>(
        context: context,
        builder: (context) => const AdminSetupPanel(),
      );
      if (setup != true) return;
      if (!context.mounted) return;
    }

    final authed = await showRightSidePanel<bool>(
      context: context,
      builder: (context) => const AdminAuthPanel(title: 'Ajouter un produit'),
    );
    
    if (authed == true) {
      if (context.mounted) {
        showRightSidePanel(
          context: context,
          builder: (context) => const AddProductPanel(),
        );
      }
    }
  }

  void _showCategoriesPanel(BuildContext context, WidgetRef ref) async {
    final hasPin = ref.read(adminProvider.notifier).hasPin;
    if (!hasPin) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez configurer un PIN en ajoutant un produit d\'abord.')));
      return;
    }

    final authed = await showRightSidePanel<bool>(
      context: context,
      builder: (context) => const AdminAuthPanel(title: 'Gérer les catégories'),
    );

    if (authed == true && context.mounted) {
      showRightSidePanel(
        context: context,
        builder: (context) => const CategoriesPanel(),
      );
    }
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
                  'Produits',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Row(
                  children: [
                    SecondaryButton(
                      text: 'Catégories',
                      icon: Icons.folder,
                      onPressed: () => _showCategoriesPanel(context, ref),
                    ),
                    const SizedBox(width: 16),
                    PrimaryButton(
                      text: 'Ajouter un produit',
                      icon: Icons.add,
                      onPressed: () => _showAddProductPanel(context, ref),
                    ),
                  ],
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
                      child: _buildProductsTable(context, ref),
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
                hintText: 'Rechercher par nom, SKU ou code-barres',
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
            text: 'Importer Excel/CSV',
            icon: Icons.upload_file,
            onPressed: () {},
          ),
          const SizedBox(width: 16),
          SecondaryButton(
            text: 'Exporter',
            icon: Icons.download,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTable(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(settingsProvider).currency;
    final productsAsync = ref.watch(productsStreamProvider);
    
    return productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Erreur: $err')),
      data: (products) {
        if (products.isEmpty) {
          return const Center(child: Text('Aucun produit trouvé.'));
        }

        return ListView(
          children: [
            DataTable(
              headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              columns: const [
                DataColumn(label: Text('Produit')),
                DataColumn(label: Text('SKU')),
                DataColumn(label: Text('Catégorie')),
                DataColumn(label: Text('Prix Vente')),
                DataColumn(label: Text('Stock')),
                DataColumn(label: Text('Statut')),
                DataColumn(label: Text('Actions')),
              ],
              rows: products.map((product) {
                final inStock = product.stockQuantity > product.minimumStock;
                return DataRow(
                  cells: [
                    DataCell(Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: product.imagePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(File(product.imagePath!), fit: BoxFit.cover),
                                )
                              : const Icon(Icons.image, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    )),
                    DataCell(Text(product.sku ?? '-')),
                    DataCell(Text(product.categoryId?.toString() ?? '-')),
                    DataCell(Text('${product.sellingPrice} $currency')),
                    DataCell(Text('${product.stockQuantity} ${product.unit}')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: inStock ? AppTheme.successColor.withOpacity(0.1) : AppTheme.dangerColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          inStock ? 'En stock' : 'Stock faible',
                          style: TextStyle(
                            color: inStock ? AppTheme.successColor : AppTheme.dangerColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20, color: Colors.blue), 
                            onPressed: () async {
                              final hasPin = ref.read(adminProvider.notifier).hasPin;
                              if (!hasPin) return; // Normally ask for setup, but keep brief
                              final authed = await showRightSidePanel<bool>(
                                context: context,
                                builder: (context) => const AdminAuthPanel(title: 'Modifier un produit'),
                              );
                              if (authed == true && context.mounted) {
                                // Show edit panel (we can reuse AddProductPanel or similar in the future)
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Édition autorisée (Mode édition à venir)')));
                              }
                            }
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20, color: Colors.red), 
                            onPressed: () async {
                              final hasPin = ref.read(adminProvider.notifier).hasPin;
                              if (!hasPin) return;
                              final authed = await showRightSidePanel<bool>(
                                context: context,
                                builder: (context) => const AdminAuthPanel(title: 'Supprimer un produit'),
                              );
                              if (authed == true && context.mounted) {
                                // Delete from DB
                                final db = ref.read(databaseProvider);
                                await (db.delete(db.products)..where((p) => p.id.equals(product.id))).go();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${product.name} supprimé'), backgroundColor: AppTheme.dangerColor),
                                );
                              }
                            }
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
