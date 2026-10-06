import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/right_side_panel.dart';
import '../../core/widgets/admin_auth_panel.dart';
import '../../core/widgets/admin_setup_panel.dart';
import '../../core/providers/admin_provider.dart';
import '../../core/database/database_provider.dart';
import 'widgets/add_product_panel.dart';
import 'widgets/categories_panel.dart';
import 'providers/product_provider.dart';
import '../settings/providers/settings_provider.dart';
import 'utils/import_export_service.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  void _showAddProductPanel(BuildContext context, WidgetRef ref) async {
    final hasPin = ref.read(adminProvider.notifier).hasPin;
    if (!hasPin) {
      final setup = await showRightSidePanel<bool>(
        context: context, builder: (context) => const AdminSetupPanel(),
      );
      if (setup != true) return;
      if (!context.mounted) return;
    }
    final authed = await showRightSidePanel<bool>(
      context: context, builder: (context) => const AdminAuthPanel(title: 'Ajouter un produit'),
    );
    if (authed == true && context.mounted) {
      showRightSidePanel(context: context, builder: (context) => const AddProductPanel());
    }
  }

  void _showEditProductPanel(BuildContext context, WidgetRef ref, product) async {
    final hasPin = ref.read(adminProvider.notifier).hasPin;
    if (!hasPin) return;
    final authed = await showRightSidePanel<bool>(
      context: context, builder: (context) => const AdminAuthPanel(title: 'Modifier le produit'),
    );
    if (authed == true && context.mounted) {
      showRightSidePanel(context: context, builder: (context) => AddProductPanel(product: product));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(settingsProvider).currency;
    final productsAsync = ref.watch(productsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Inventaire', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                    productsAsync.when(
                      loading: () => const Text('Chargement…', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (p) => Text('${p.length} produit(s)', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ),
                  ],
                ),
                const Spacer(),
                // Search bar
                SizedBox(
                  width: 260,
                  height: 36,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Rechercher…',
                      hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, size: 16, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Import/Export
                PopupMenuButton<String>(
                  tooltip: 'Import / Export',
                  icon: const Icon(Icons.import_export, size: 20, color: AppTheme.primaryColor),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'template', child: Text('Télécharger modèle CSV', style: TextStyle(fontSize: 13))),
                    PopupMenuItem(value: 'import', child: Text('Importer CSV', style: TextStyle(fontSize: 13))),
                    PopupMenuItem(value: 'export', child: Text('Exporter CSV', style: TextStyle(fontSize: 13))),
                  ],
                  onSelected: (value) async {
                    final db = ref.read(databaseProvider);
                    final service = ImportExportService(db);
                    if (value == 'template') {
                      final path = await service.downloadTemplate();
                      if (context.mounted && path != null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Modèle: $path'), backgroundColor: AppTheme.successColor));
                      }
                    } else if (value == 'import') {
                      try {
                        final count = await service.importProducts();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$count produits importés!'), backgroundColor: AppTheme.successColor));
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: AppTheme.dangerColor));
                        }
                      }
                    } else if (value == 'export') {
                      final path = await service.exportProducts();
                      if (context.mounted && path != null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exporté: $path'), backgroundColor: AppTheme.successColor));
                      }
                    }
                  },
                ),
                const SizedBox(width: 6),
                // Categories
                OutlinedButton.icon(
                  icon: const Icon(Icons.folder_outlined, size: 16),
                  label: const Text('Catégories', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () async {
                    final hasPin = ref.read(adminProvider.notifier).hasPin;
                    if (!hasPin) return;
                    final authed = await showRightSidePanel<bool>(
                      context: context, builder: (context) => const AdminAuthPanel(title: 'Catégories'),
                    );
                    if (authed == true && context.mounted) {
                      showRightSidePanel(context: context, builder: (context) => const CategoriesPanel());
                    }
                  },
                ),
                const SizedBox(width: 8),
                // Add button
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Ajouter', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111111),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => _showAddProductPanel(context, ref),
                ),
              ],
            ),
          ),

          // ── Table ──
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur: $e')),
              data: (allProducts) {
                final products = _searchQuery.isEmpty
                    ? allProducts
                    : allProducts.where((p) =>
                        p.name.toLowerCase().contains(_searchQuery) ||
                        (p.sku?.toLowerCase().contains(_searchQuery) ?? false) ||
                        (p.barcode?.toLowerCase().contains(_searchQuery) ?? false)).toList();

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(_searchQuery.isEmpty ? 'Aucun produit. Appuyez sur « Ajouter ».' : 'Aucun résultat.',
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      children: [
                        // Table header
                        Container(
                          color: const Color(0xFFF9FAFB),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: const Row(
                            children: [
                              SizedBox(width: 32),
                              SizedBox(width: 8),
                              Expanded(flex: 4, child: _TH('Produit')),
                              Expanded(flex: 2, child: _TH('SKU / Code')),
                              Expanded(flex: 2, child: _TH('Prix Achat')),
                              Expanded(flex: 2, child: _TH('Prix Vente')),
                              Expanded(flex: 2, child: _TH('Stock')),
                              SizedBox(width: 80, child: _TH('Actions')),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),
                        // Rows
                        Expanded(
                          child: ListView.separated(
                            itemCount: products.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                            itemBuilder: (context, i) {
                              final p = products[i];
                              final isLow = p.stockQuantity <= p.minimumStock;
                              return Container(
                                color: i.isEven ? Colors.white : const Color(0xFFFAFAFC),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  children: [
                                    // Thumbnail
                                    Container(
                                      width: 32, height: 32,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF9C3),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: p.imagePath != null
                                          ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(p.imagePath!), fit: BoxFit.cover))
                                          : Center(
                                              child: Text(p.name.substring(0, 1).toUpperCase(),
                                                  style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFCA8A04), fontSize: 13)),
                                            ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Name
                                    Expanded(flex: 4, child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis)),
                                    // SKU
                                    Expanded(flex: 2, child: Text(p.sku ?? p.barcode ?? '—', style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF), fontFamily: 'monospace'))),
                                    // Purchase price
                                    Expanded(flex: 2, child: Text('${p.purchasePrice.toStringAsFixed(0)} $currency', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
                                    // Selling price
                                    Expanded(flex: 2, child: Text('${p.sellingPrice.toStringAsFixed(0)} $currency', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF16A34A)))),
                                    // Stock badge
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isLow ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '${p.stockQuantity.toStringAsFixed(p.stockQuantity % 1 == 0 ? 0 : 1)} ${p.unit}',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isLow ? const Color(0xFFDC2626) : const Color(0xFF16A34A)),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    // Actions
                                    SizedBox(
                                      width: 80,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _ActionBtn(icon: Icons.edit_outlined, color: const Color(0xFF3B82F6), onPressed: () => _showEditProductPanel(context, ref, p)),
                                          const SizedBox(width: 4),
                                          _ActionBtn(
                                            icon: Icons.delete_outline,
                                            color: const Color(0xFFEF4444),
                                            onPressed: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: const Text('Supprimer?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                                  content: Text('Supprimer « ${p.name} » définitivement?', style: const TextStyle(fontSize: 14)),
                                                  actions: [
                                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
                                                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
                                                  ],
                                                ),
                                              );
                                              if (confirm == true) {
                                                final db = ref.read(databaseProvider);
                                                await (db.delete(db.products)..where((t) => t.id.equals(p.id))).go();
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper widgets ──

class _TH extends StatelessWidget {
  final String text;
  const _TH(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF), letterSpacing: 0.5),
  );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  const _ActionBtn({required this.icon, required this.color, required this.onPressed});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onPressed,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      width: 30, height: 30,
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 15, color: color),
    ),
  );
}
