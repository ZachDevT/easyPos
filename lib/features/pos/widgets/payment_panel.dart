import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/database/database.dart';
import '../../../core/database/database_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/session_provider.dart';
import '../../customers/providers/customer_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/utils/printer_service.dart';

class PaymentPanel extends ConsumerStatefulWidget {
  final double totalAmount;

  const PaymentPanel({super.key, required this.totalAmount});

  @override
  ConsumerState<PaymentPanel> createState() => _PaymentPanelState();
}

class _PaymentPanelState extends ConsumerState<PaymentPanel> {
  String _selectedMethod = 'ESPÈCES';
  final _tenderedController = TextEditingController();
  int? _selectedCustomerId;

  @override
  void initState() {
    super.initState();
    _tenderedController.text = widget.totalAmount.toString();
  }

  @override
  void dispose() {
    _tenderedController.dispose();
    super.dispose();
  }

  
  Future<void> _processPayment() async {
    final sessionAsync = ref.read(activeSessionProvider);
    final session = sessionAsync.valueOrNull;

    if (session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune caisse ouverte.')),
      );
      return;
    }

    if (_selectedMethod == 'CRÉDIT' && _selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner un client pour le crédit.')));
      return;
    }

    final db = ref.read(databaseProvider);
    final cartItems = ref.read(cartProvider);

    // Run in a transaction
    final insertedSaleId = await db.transaction(() async {
      // 1. Create Sale
      final saleId = await db.into(db.sales).insert(
        SalesCompanion.insert(
          saleNumber: 'FAC-${DateTime.now().millisecondsSinceEpoch}', // Basic generation
          date: DateTime.now(),
          subtotal: widget.totalAmount,
          discount: const drift.Value(0.0),
          total: widget.totalAmount,
          paymentMethod: drift.Value(_selectedMethod),
          sessionId: drift.Value(session.id),
        ),
      );

      // 2. Create Sale Items and deduct stock
      for (final item in cartItems) {
        await db.into(db.saleItems).insert(
          SaleItemsCompanion.insert(
            saleId: saleId,
            productId: item.productId,
            quantity: item.quantity.toDouble(),
            unitPrice: item.price,
            total: item.total,
          ),
        );

        // Deduct stock
        final product = await (db.select(db.products)..where((p) => p.id.equals(item.productId))).getSingle();
        await (db.update(db.products)..where((p) => p.id.equals(item.productId))).write(
          ProductsCompanion(
            stockQuantity: drift.Value(product.stockQuantity - item.quantity),
          ),
        );
      }

      // 3. Update customer credit if needed
      if (_selectedMethod == 'CRÉDIT' && _selectedCustomerId != null) {
        final customer = await (db.select(db.customers)..where((c) => c.id.equals(_selectedCustomerId!))).getSingle();
        await (db.update(db.customers)..where((c) => c.id.equals(_selectedCustomerId!))).write(
          CustomersCompanion(
            totalCredit: drift.Value(customer.totalCredit + widget.totalAmount),
          ),
        );
      }
      return saleId;
    });

    // Generate Print Preview BEFORE popping
    final sale = await (db.select(db.sales)..where((s) => s.id.equals(insertedSaleId))).getSingle();
    final printedItems = await (db.select(db.saleItems)..where((si) => si.saleId.equals(insertedSaleId))).get();
    final allProducts = await (db.select(db.products)).get();
    final settings = ref.read(settingsProvider);

    // 4. Clear cart
    ref.read(cartProvider.notifier).clearCart();
    ref.invalidate(dashboardStatsProvider);

    if (mounted) {
      // Show printing preview Dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paiement réussi ! Impression...', style: TextStyle(color: Colors.white)), backgroundColor: AppTheme.successColor),
      );
      
      // Print will show the native preview UI
      await PrinterService.printReceipt(sale, printedItems, allProducts, settings.currency, settings.storeName, settings.receiptFooter);
      
      if (mounted) Navigator.of(context).pop(true);
    }
  }


  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(settingsProvider).currency;
        return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total à payer', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  Text('${widget.totalAmount} $currency', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            Text('Mode de paiement', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildPaymentMethod('ESPÈCES', Icons.money),
                _buildPaymentMethod('MOBILE MONEY', Icons.phone_android),
                _buildPaymentMethod('CARTE', Icons.credit_card),
                _buildPaymentMethod('CRÉDIT', Icons.book),
              ],
            ),
            const SizedBox(height: 32),
            

            if (_selectedMethod == 'CRÉDIT') ...[
              const Text('Client', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ref.watch(customersStreamProvider).when(
                loading: () => const CircularProgressIndicator(),
                error: (e, st) => Text('Erreur: $e'),
                data: (customers) {
                  return DropdownButtonFormField<int>(
                    value: _selectedCustomerId,
                    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    hint: const Text('Sélectionner un client'),
                    items: customers.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (val) => setState(() => _selectedCustomerId = val),
                  );
                },
              ),
            ],

            if (_selectedMethod == 'ESPÈCES') ...[
              Text('Montant reçu ($currency)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _tenderedController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.payments),
                ),
                style: const TextStyle(fontSize: 24),
                onChanged: (val) => setState(() {}), // To trigger change in change due
              ),
              const SizedBox(height: 16),
              _buildChangeDue(),
            ],
            
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: 'Valider le paiement',
                icon: Icons.check_circle,
                onPressed: _processPayment,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(String method, IconData icon) {
    final isSelected = _selectedMethod == method;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = method),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              method,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeDue() {
    final currency = ref.watch(settingsProvider).currency;
    final tendered = double.tryParse(_tenderedController.text) ?? 0.0;
    final change = tendered - widget.totalAmount;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: change >= 0 ? AppTheme.successColor.withOpacity(0.1) : AppTheme.dangerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Monnaie à rendre', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(
            change >= 0 ? '$change $currency' : 'Montant insuffisant',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: change >= 0 ? AppTheme.successColor : AppTheme.dangerColor,
            ),
          ),
        ],
      ),
    );
  }
}
