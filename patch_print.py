import os
import re

with open('lib/features/pos/widgets/payment_panel.dart', 'r') as f:
    content = f.read()

# Add PrinterService import if not there
if "import '../../../core/utils/printer_service.dart';" not in content:
    content = content.replace("import '../../settings/providers/settings_provider.dart';", "import '../../settings/providers/settings_provider.dart';\nimport '../../../core/utils/printer_service.dart';")

# Find the _processPayment logic around lines 107-118
print_logic = '''
    // Fetch objects for printing
    final sale = await (db.select(db.sales)..where((s) => s.id.equals(saleId))).getSingle();
    final printedItems = await (db.select(db.saleItems)..where((si) => si.saleId.equals(saleId))).get();
    final allProducts = await (db.select(db.products)).get();
    final settings = ref.read(settingsProvider);
    
    // Trigger Print/Preview
    await PrinterService.printReceipt(sale, printedItems, allProducts, settings.currency, settings.storeName, settings.receiptFooter);

    // 4. Clear cart
    ref.read(cartProvider.notifier).clearCart();
'''
# We need to extract saleId from the insert, wait, it is already assigned to `final saleId = await db.into...`
# But it's inside `db.transaction(() async { ... })` scope! 
# We should return `saleId` from the transaction.

new_process_payment = '''
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
'''
content = re.sub(r'Future<void> _processPayment\(\) async \{[\s\S]*?Navigator\.of\(context\)\.pop\(true\);\n    }\n  }', new_process_payment, content)

with open('lib/features/pos/widgets/payment_panel.dart', 'w') as f:
    f.write(content)

print("Payment print logic injected!")
