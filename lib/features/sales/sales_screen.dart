import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/theme/app_theme.dart';
import '../../core/database/database.dart';
import '../../core/database/database_provider.dart';
import '../../core/utils/printer_service.dart';
import 'providers/sales_provider.dart';
import '../settings/providers/settings_provider.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _processRefund(WidgetRef ref, sale) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rembourser / Retourner ?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Voulez-vous annuler la facture ${sale.saleNumber} et retourner les articles en stock ?', style: const TextStyle(fontSize: 14)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Rembourser'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final db = ref.read(databaseProvider);
      final items = await (db.select(db.saleItems)..where((i) => i.saleId.equals(sale.id))).get();

      await db.transaction(() async {
        // 1. Restock items
        for (final item in items) {
          final product = await (db.select(db.products)..where((p) => p.id.equals(item.productId))).getSingleOrNull();
          if (product != null) {
            await (db.update(db.products)..where((p) => p.id.equals(product.id))).write(
              ProductsCompanion(stockQuantity: drift.Value(product.stockQuantity + item.quantity))
            );
          }
        }
        // 2. Delete items
        await (db.delete(db.saleItems)..where((i) => i.saleId.equals(sale.id))).go();
        // 3. Delete sale
        await (db.delete(db.sales)..where((s) => s.id.equals(sale.id))).go();
      });

      // Attempt remote delete if connected
      try {
        await Supabase.instance.client.from('sales').delete().eq('id', sale.id);
      } catch (_) {}

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Remboursement effectué et stock mis à jour.'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          )
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppTheme.dangerColor)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(settingsProvider).currency;
    final salesAsync = ref.watch(salesHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Transactions', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                    salesAsync.when(
                      loading: () => const Text('Chargement…', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (s) => Text('${s.length} facture(s)', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    ),
                  ],
                ),
                const Spacer(),
                // Search bar
                SizedBox(
                  width: 280,
                  height: 42,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Rechercher une facture...',
                      hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                      prefixIcon: const HugeIcon(icon: HugeIcons.strokeRoundedSearch01, size: 18, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Export button
                OutlinedButton.icon(
                  icon: const HugeIcon(icon: HugeIcons.strokeRoundedDownload04, size: 18, color: AppTheme.textColor),
                  label: const Text('Exporter', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final salesData = ref.read(salesHistoryProvider).valueOrNull;
                    if (salesData == null || salesData.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aucune donnée à exporter')));
                      return;
                    }
                    
                    List<List<dynamic>> rows = [];
                    rows.add(["Date", "Facture", "Méthode", "Total"]);
                    for (var s in salesData) {
                      rows.add([
                        s.date.toIso8601String(),
                        s.saleNumber,
                        s.paymentMethod,
                        s.total
                      ]);
                    }
                    
                    String csv = ListToCsvConverter().convert(rows);
                    try {
                      final dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
                      final file = File('${dir.path}/Ventes_${DateTime.now().millisecondsSinceEpoch}.csv');
                      await file.writeAsString(csv);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exporté vers ${file.path}'), duration: const Duration(seconds: 4)));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur export: $e')));
                    }
                  },
                ),
              ],
            ),
          ),

          // ── Table ──
          Expanded(
            child: salesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur: $e')),
              data: (allSales) {
                final sales = _searchQuery.isEmpty
                    ? allSales
                    : allSales.where((s) => s.saleNumber.toLowerCase().contains(_searchQuery)).toList();

                if (sales.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const HugeIcon(icon: HugeIcons.strokeRoundedInvoice01, size: 48, color: Color(0xFFD1D5DB)),
                        const SizedBox(height: 12),
                        Text(_searchQuery.isEmpty ? 'Aucune vente enregistrée.' : 'Aucun résultat.',
                            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }

                return Container(
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Column(
                      children: [
                        // Table header
                        Container(
                          color: const Color(0xFFF9FAFB),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          child: const Row(
                            children: [
                              SizedBox(width: 42), // Avatar placeholder space
                              SizedBox(width: 12),
                              Expanded(flex: 3, child: _TH('N° Facture')),
                              Expanded(flex: 2, child: _TH('Date')),
                              Expanded(flex: 2, child: _TH('Total')),
                              Expanded(flex: 2, child: _TH('Paiement')),
                              SizedBox(width: 120, child: _TH('Actions', alignRight: true)),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),
                        // Rows
                        Expanded(
                          child: ListView.separated(
                            itemCount: sales.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                            itemBuilder: (context, i) {
                              final s = sales[i];
                              final d = s.date;
                              final dateStr = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
                              
                              return Container(
                                color: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                child: Row(
                                  children: [
                                    // Avatar
                                    Container(
                                      width: 42, height: 42,
                                      decoration: BoxDecoration(
                                        color: AppTheme.pastelBlue,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: HugeIcon(icon: HugeIcons.strokeRoundedInvoice01, size: 20, color: Color(0xFF3B82F6)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Invoice Number
                                    Expanded(flex: 3, child: Text(s.saleNumber, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: -0.2))),
                                    // Date
                                    Expanded(flex: 2, child: Text(dateStr, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)))),
                                    // Total
                                    Expanded(
                                      flex: 2, 
                                      child: Text('${s.total.toStringAsFixed(0)} $currency', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textColor))
                                    ),
                                    // Payment Method
                                    Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: _PaymentBadge(s.paymentMethod))),
                                    // Actions
                                    SizedBox(
                                      width: 120,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          _ActionBtn(
                                            tooltip: 'Imprimer le ticket',
                                            icon: HugeIcons.strokeRoundedPrinter, 
                                            color: const Color(0xFF6B7280), 
                                            onPressed: () async {
                                              final db = ref.read(databaseProvider);
                                              final items = await (db.select(db.saleItems)..where((i) => i.saleId.equals(s.id))).get();
                                              final productIds = items.map((i) => i.productId).toList();
                                              final products = await (db.select(db.products)..where((p) => p.id.isIn(productIds))).get();
                                              final settings = ref.read(settingsProvider);
                                              await PrinterService.printReceipt(s, items, products, settings.currency, settings.storeName, settings.receiptFooter);
                                            }
                                          ),
                                          const SizedBox(width: 8),
                                          _ActionBtn(
                                            tooltip: 'Annuler et Rembourser',
                                            icon: HugeIcons.strokeRoundedArrowTurnBackward, 
                                            color: AppTheme.dangerColor, 
                                            onPressed: () => _processRefund(ref, s),
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
  final bool alignRight;
  const _TH(this.text, {this.alignRight = false});
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    textAlign: alignRight ? TextAlign.right : TextAlign.left,
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF), letterSpacing: 0.5),
  );
}

class _ActionBtn extends StatelessWidget {
  final List<List<dynamic>> icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;
  const _ActionBtn({required this.icon, required this.color, required this.tooltip, required this.onPressed});
  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: HugeIcon(icon: icon, size: 18, color: color),
      ),
    ),
  );
}

class _PaymentBadge extends StatelessWidget {
  final String method;
  const _PaymentBadge(this.method);

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bg;
    
    switch (method.toUpperCase()) {
      case 'MOBILE MONEY':
        color = const Color(0xFFD97706);
        bg = const Color(0xFFFEF3C7);
        break;
      case 'CARTE':
        color = const Color(0xFF7C3AED);
        bg = const Color(0xFFEDE9FE);
        break;
      case 'CRÉDIT':
        color = const Color(0xFFDC2626);
        bg = const Color(0xFFFEE2E2);
        break;
      default:
        color = const Color(0xFF059669);
        bg = const Color(0xFFD1FAE5);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        method,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
