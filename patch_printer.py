import os

with open('lib/core/utils/printer_service.dart', 'r') as f:
    content = f.read()

content = content.replace(
    'static Future<void> printReceipt(Sale sale, List<SaleItem> items, List<Product> products) async {',
    'static Future<void> printReceipt(Sale sale, List<SaleItem> items, List<Product> products, String currency, String storeName, String footer) async {'
)
content = content.replace("'EasyPOS'", "storeName")
content = content.replace("'Merci pour votre visite!'", "footer")
content = content.replace(" CDF'", " $currency'")

with open('lib/core/utils/printer_service.dart', 'w') as f:
    f.write(content)

with open('lib/features/sales/sales_screen.dart', 'r') as f:
    content = f.read()

content = content.replace(
    'await PrinterService.printReceipt(sale, items, products);',
    'final settings = ref.read(settingsProvider);\n                              await PrinterService.printReceipt(sale, items, products, settings.currency, settings.storeName, settings.receiptFooter);'
)

with open('lib/features/sales/sales_screen.dart', 'w') as f:
    f.write(content)
