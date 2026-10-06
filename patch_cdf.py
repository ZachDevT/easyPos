import os
import re

def patch_file(filepath, imports, ref_injector, text_replacements):
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Add imports if not present
    for imp in imports:
        if imp not in content:
            # add after last import
            last_import_idx = content.rfind("import '")
            end_of_last_import = content.find(";", last_import_idx) + 1
            content = content[:end_of_last_import] + f"\n{imp}" + content[end_of_last_import:]
            
    # Inject currency variable
    for target, injection in ref_injector.items():
        if injection not in content:
            content = content.replace(target, target + "\n" + injection)
            
    # Replace strings
    for old, new in text_replacements.items():
        content = content.replace(old, new)
        
    with open(filepath, 'w') as f:
        f.write(content)

# 1. dashboard_screen.dart
patch_file(
    'lib/features/dashboard/dashboard_screen.dart',
    ["import '../../features/settings/providers/settings_provider.dart';"],
    {"Widget build(BuildContext context, WidgetRef ref) {": "    final currency = ref.watch(settingsProvider).currency;"},
    {"'${stats.totalSales} CDF'": "'${stats.totalSales} $currency'",
     "'${stats.estimatedProfit} CDF'": "'${stats.estimatedProfit} $currency'"}
)

# 2. pos_screen.dart
patch_file(
    'lib/features/pos/pos_screen.dart',
    ["import '../../features/settings/providers/settings_provider.dart';"],
    {"Widget build(BuildContext context, WidgetRef ref) {": "    final currency = ref.watch(settingsProvider).currency;"},
    {"'${product.sellingPrice} CDF'": "'${product.sellingPrice} $currency'",
     "'${item.total} CDF'": "'${item.total} $currency'",
     "'$subtotal CDF'": "'$subtotal $currency'",
     "'0 CDF'": "'0 $currency'",
     "'$total CDF'": "'$total $currency'"}
)

# 3. payment_panel.dart
patch_file(
    'lib/features/pos/widgets/payment_panel.dart',
    ["import '../../settings/providers/settings_provider.dart';"],
    {"Widget build(BuildContext context) {": "    final currency = ref.watch(settingsProvider).currency;"},
    {"'${widget.totalAmount} CDF'": "'${widget.totalAmount} $currency'",
     "Montant reçu (CDF)": "Montant reçu ($currency)",
     "'$change CDF'": "'$change $currency'"}
)

# 4. opening_balance_dialog.dart
patch_file(
    'lib/features/pos/widgets/opening_balance_dialog.dart',
    ["import '../../settings/providers/settings_provider.dart';"],
    {"Widget build(BuildContext context) {": "    final currency = ref.watch(settingsProvider).currency;"},
    {"Fond de caisse (CDF)": "Fond de caisse ($currency)"}
)

# 5. closing_balance_panel.dart
patch_file(
    'lib/features/pos/widgets/closing_balance_panel.dart',
    ["import '../../settings/providers/settings_provider.dart';"],
    {"Widget build(BuildContext context) {": "    final currency = ref.watch(settingsProvider).currency;"},
    {" CDF'": " $currency'", " (CDF)": " ($currency)"}
)

# 6. products_screen.dart
patch_file(
    'lib/features/products/products_screen.dart',
    ["import '../settings/providers/settings_provider.dart';"],
    {"Widget _buildProductsTable(BuildContext context, WidgetRef ref) {": "    final currency = ref.watch(settingsProvider).currency;"},
    {"'${product.sellingPrice} CDF'": "'${product.sellingPrice} $currency'"}
)

# 7. add_product_panel.dart
patch_file(
    'lib/features/products/widgets/add_product_panel.dart',
    ["import '../../settings/providers/settings_provider.dart';"],
    {"Widget build(BuildContext context) {": "    final currency = ref.watch(settingsProvider).currency;"},
    {"(CDF)": "($currency)"}
)

# 8. sales_screen.dart
patch_file(
    'lib/features/sales/sales_screen.dart',
    ["import '../settings/providers/settings_provider.dart';"],
    {"Widget _buildSalesTable(WidgetRef ref) {": "    final currency = ref.watch(settingsProvider).currency;"},
    {"'${sale.total} CDF'": "'${sale.total} $currency'"}
)

# 9. customers_screen.dart
patch_file(
    'lib/features/customers/customers_screen.dart',
    ["import '../settings/providers/settings_provider.dart';"],
    {"Widget _buildCustomersTable(WidgetRef ref) {": "    final currency = ref.watch(settingsProvider).currency;"},
    {"'${c.totalCredit} CDF'": "'${c.totalCredit} $currency'"}
)

print("Patching complete!")
